## SPARQL Gotcha


Using Wikidata let's look for a connection between President Obama (Q76) and Paul Simon (Q4028).


Are they directly connected?

```
select * {
{?s ?p ?o .}
union
{?o ?p ?s .}
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```
[1]


That query looks for these 2 triple patterns:
```
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - - - +
' President Obama ' --> ' some predicate ' --> '   Paul Simon    '
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - - - +

+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - - - +
'   Paul Simon    ' --> ' some predicate ' --> ' President Obama '
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - - - +
```


There are no results found.



Do they have one node between them?

```
select *     {
?s ?p ?o .
?o ?p1 ?o1 .
filter(?s=wd:Q76 ).
filter(?o1=wd:Q4028).
} 
```

No results -- but notice that the query only looks for two triples:
```
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - -+
' President Obama ' --> ' some predicate ' --> ' some object ' --> ' some predicate ' --> ' Paul Simon '
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - -+
```


That query will not find these two triples:
```
+ - - - - - -+     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - - - - +
' Paul Simon ' --> ' some predicate ' --> ' some object ' --> ' some predicate ' --> ' President Obama '
+ - - - - - -+     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - - - - +
```

We could update the filter to allow ?s and ?o1 to be Q76 or Q4028 (but not the same) but we'd still be missing a possible connection.

That possible connection we wouldn't find is this:
```
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +
' President Obama ' --> ' some predicate ' --> ' some object '
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +
                                                 ^
                                                 |
                                                 |
+ - - - - - - - - +     + - - - - - - - -+       |
'   Paul Simon    ' --> ' some predicate ' ------+
+ - - - - - - - - +     + - - - - - - - -+
```
[2]


And it is that very connection that is in the graph.
Next let's see how we could find a connection, in general, without worry about the specific sequence of directed edges.




Do President Obama and Paul Simon have one node between them (trying all possible orders)?
```
select * {
?s ((<>|!<>)|^(<>|!<>))/((<>|!<>)|^(<>|!<>)) ?o .
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```

Yes they do!
```
s                                  | o                                    ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q4028 ‖
```
There are 9 paths between them.
That query makes use of [property paths](https://www.w3.org/TR/sparql11-property-paths/#path-language).
But it does not show what the paths are.


This query will at least show you what the node in the middle is:
```
select * {
?s ((<>|!<>)|^(<>|!<>)) ?node .
?node ((<>|!<>)|^(<>|!<>)) ?o .
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```

Results:
```
s                                  | node                                     | o                                    ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q5        | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q30       | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q6581097  | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/L485      | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q1860     | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q1860     | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q1860     | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q463303   | http://www.wikidata.org/entity/Q4028 ‖
http://www.wikidata.org/entity/Q76 | http://www.wikidata.org/entity/Q67311526 | http://www.wikidata.org/entity/Q4028 ‖
```

This is an improvement. For example wd:Q5 is "human." So it looks like one way President Obama and Paul Simon are connected is by the fact that they are both human.



If you want to see what the predicates are in those paths you have to add some additional patterns.
And after some exploration you arrive at the right sequence of patterns:

```
select ?sLabel ?pEntityLabel ?oLabel ?p1EntityLabel ?s1Label        {
 ?s ?p ?o .
 filter(?s = wd:Q76 ) .
 ?s1 ?p1 ?o .
 filter (isUri(?o)) .
 filter (?s1=wd:Q4028) .
optional {?p ^(wikibase:claim|wikibase:directClaim|wikibase:statementProperty) ?pEntity} .
optional {?p1 ^(wikibase:claim|wikibase:directClaim|wikibase:statementProperty) ?p1Entity} .
SERVICE wikibase:label { bd:serviceParam wikibase:language "en". } .
} 
```

We can see that Paul Simon and President Obama share some common attributes:
```
||sLabel       ||pEntityLabel                        ||oLabel                                ||p1EntityLabel                       ||s1Label    |
|Barack Obama  |member of                            |American Academy of Arts and Sciences  |member of                            |Paul Simon  |
|Barack Obama  |described by source                  |Obalky knih.cz                         |described by source                  |Paul Simon  |
|Barack Obama  |languages spoken, written or signed  |English                                |languages spoken, written or signed  |Paul Simon  |
|Barack Obama  |writing language                     |English                                |languages spoken, written or signed  |Paul Simon  |
|Barack Obama  |native language                      |English                                |languages spoken, written or signed  |Paul Simon  |
|Barack Obama  |personal pronoun                     |L485                                   |personal pronoun                     |Paul Simon  |
|Barack Obama  |sex or gender                        |male                                   |sex or gender                        |Paul Simon  |
|Barack Obama  |instance of                          |human                                  |instance of                          |Paul Simon  |
|Barack Obama  |country of citizenship               |United States of America               |country of citizenship               |Paul Simon  |
```



Because SPARQL that makes this `((<>|!<>)|^(<>|!<>))` necessary is t





---
[1]    In order to run this query yourself you can use this bash command:

```
curl --silent -H 'Accept: text/csv' 'https://query.wikidata.org/sparql'  \
--data-urlencode 'query=
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX wd:       <http://www.wikidata.org/entity/>         # Wikibase entity - item or property. 
PREFIX wdt:      <http://www.wikidata.org/prop/direct/>    # Truthy assertions about the data, links entity to value directly. 
PREFIX p:        <http://www.wikidata.org/prop/>           # Links entity to statement 
PREFIX ps:       <http://www.wikidata.org/prop/statement/> # Links value to statement 
PREFIX pq:       <http://www.wikidata.org/prop/qualifier/> # Links qualifier to statement node 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX bd: <http://www.bigdata.com/rdf#>
prefix sch: <https://schema.org/>
select *     {
{?s ?p ?o .}
union
{?o ?p ?s .}
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
limit 300'
```


[2]   If you want to make ASCII graphs like this you can use [graph-easy-box](https://github.com/justin2004/graph-easy-box).
See `some.dg` in this directory.
