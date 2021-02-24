# SPARQL Gotcha


Using [Wikidata](https://www.wikidata.org) let's look for a connection between President Obama (Q76) and Paul Simon (Q4028).


## Are they directly connected?

It would be ideal, for an exploratory query session, if we could just run this query:

```
select * {
?s ?p ?o .
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```
[1]

But in RDF edges are directed so that query only looks triples whose subject is President Obama and whose object is Paul Simon.
It would not find triples who subject is Paul Simon and whose object is President Obama.
(There is a way to make this ideal query do what we'd like it to do but I'll describe that at the end on this post.)

In order to not care about the direction of the edge we'd need to run this:
```
select * {
{?s ?p ?o .}
union
{?o ?p ?s .}
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```
[2]


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



## Are they indirectly connected? 
#### Do they have one node between them?

```
select *     {
?s ?p ?o .
?o ?p1 ?o1 .
filter(?s=wd:Q76 ).
filter(?o1=wd:Q4028).
} 
```

No results -- but notice that the query only looks for two back to back triple patterns:
```
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - -+
' President Obama ' --> ' some predicate ' --> ' some object ' --> ' some predicate ' --> ' Paul Simon '
+ - - - - - - - - +     + - - - - - - - -+     + - - - - - - +     + - - - - - - - -+     + - - - - - -+
```


That query will not find these two back to back triples:
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
[3]


And it is that very connection that is in the graph.
Next let's see how we could find a connection, in general, without worry about the specific sequence of directed edges.




Do President Obama and Paul Simon have one node between them (trying all possible directed edge orders)?
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


## What are the paths between them?


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


## Closing thoughts

Since SPARQL does not have first class support for paths you do have to put more effort into the query as opposed to [Cypher](https://neo4j.com/developer/cypher/). Cypher does support paths as a first class thing.

Also Because SPARQL doesn't let you bind variables on a "backwards edge" like Cypher does, in SPARQL you have to resort to using a property path like: `((<>|!<>)|^(<>|!<>))`. And that property path doesn't let you bind the matching edge (forward or backwards) so it is only good to find *if* there is a connection -- not for finding *what* the connection is.

I do know that [Stardog](https://www.stardog.com/blog/a-path-of-our-own/) does have an extension to SPARQL that treats paths as first class but I haven't tried it yet.


I still prefer the simplicity of the RDF model and its powerful query langauge (SPARQL) over LPG models (like Neo4j). SPARQL's inability to bind a variable on a "backwards edge" and no first class support for paths only make it harder to use for exploratory querying. If you embed SPARQL in some application code you will already know what your needs are and you'll have time to make the appropriate triple and graph patterns. If you need to find paths you can do some [iterative deepening](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search).


## Quick final note
#### Making the "ideal query" work

At the beginning I said that this was an ideal query for looking for a direct connection between President Obama and Paul Simon.

```
select * {
?s ?p ?o .
filter(?s=wd:Q76 ).
filter(?o=wd:Q4028).
} 
```
I think it is ideal for the query writer because it can be expressed/typed quickly.

In order to allow this query to work as we desire, in general, we'd need to mandate that all predicates have their inverse represented. For example, if we a triple that corresponds to this statement:

`Paul Simon saw President Obama`

Upon seeing that triple we'd need to derive this triple:

`President Obama was seen by Paul Simon`

With a reasoner it is easy to set up the conditions for this to happen.
You just need reasoning enabled and these additional triples in your data:
```
:wasSeenBy a owl:ObjectProperty .

:saw a owl:ObjectProperty ;
     owl:inverseOf :wasSeenBy . 
```

But we don't just care about `:seen` and `:wasSeenBy` so we'd need to do this for every predicate (object property, specifically) in all the ontologies our data is using. Which might be a pain to do by hand but I think we could write some SPARQL do this pretty easily.

Maybe the real hurdle is that using an OWL reasoner on lots of triples is tricky business.

And if we pretend that is now easy and fast *then* we'll likely have the need or desire to reason on data in someone else's graph using an ontology we bring. I am working on something now to hopefully make that easier. Stay tuned!



---
[1]    There are some variations on this simple query. Two I can think of right now are using [VALUES](https://www.w3.org/TR/sparql11-query/#inline-data) and using a literal instead of a variable (which you filter on).

[2]    In order to run this query yourself you can use this bash command:

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


[3]   If you want to make ASCII graphs like this you can use [graph-easy-box](https://github.com/justin2004/graph-easy-box).
See `some.dg` in this directory.
