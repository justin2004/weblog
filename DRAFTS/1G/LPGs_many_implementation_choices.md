

As a metamodel, LPG (labeled property graph) has too many options on where to say things.
That means to use an LPG representation you must make implementation choices that aren't data modeling choices.

In RDF you don't have those implementation choices to make.
In RDF, there is a single way to say things: as a triple.

For example, let's say we want to talk about this paper (and its sections).
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC35282/

I'll first use an LPG representation found in [this project](https://github.com/covidgraph/data_cord19) then an RDF representation.


The following Cypher query (against a Neo4j instance):
```
match (s0)-[p0]->(s {id:"c6c001198a1ca7136a0c476b7723d9bf"})-[p:BODYTEXTCOLLECTION_HAS_BODYTEXT]->(o) 
return s0,labels(s0),p0,type(p0),s,labels(s),p,type(p),o,labels(o) order by p.position
```

yields:
```
╒══════════════════════════════════════════════════════════════════════╤════════════╤════╤══════════════════════════════╤═════════════════════════════════════════╤══════════════════════╤═══════════════╤═════════════════════════════════╤══════════════════════════════════════════════════════════════════════╤════════════╕
│"s0"                                                                  │"labels(s0)"│"p0"│"type(p0)"                    │"s"                                      │"labels(s)"           │"p"            │"type(p)"                        │"o"                                                                   │"labels(o)" │
╞══════════════════════════════════════════════════════════════════════╪════════════╪════╪══════════════════════════════╪═════════════════════════════════════════╪══════════════════════╪═══════════════╪═════════════════════════════════╪══════════════════════════════════════════════════════════════════════╪════════════╡
│{"cord_uid":"ug7v899j","cord19-fulltext_hash":"d1aafb70c066a2068b02786│["Paper"]   │{}  │"PAPER_HAS_BODYTEXTCOLLECTION"│{"id":"c6c001198a1ca7136a0c476b7723d9bf"}│["BodyTextCollection"]│{"position":0} │"BODYTEXTCOLLECTION_HAS_BODYTEXT"│{"section":"Introduction","_hash_id":"d32453131e57e46e02884893b9c039ae│["BodyText"]│
│f8929fd9c900897fb","journal":"BMC Infect Dis","publish_time":"2001-07-│            │    │                              │                                         │                      │               │                                 │","text":"Mycoplasma pneumoniae is a common cause of upper and lower r│            │
│04","source":"PMC","title":"Clinical features of culture-proven Mycopl│            │    │                              │                                         │                      │               │                                 │espiratory tract infections. It remains one of the most frequent cause│            │
│asma pneumoniae infections at King Abdulaziz University Hospital, Jedd│            │    │                              │                                         │                      │               │                                 │s of atypical pneumonia particu-larly among young adults.             │            │
│ah, Saudi Arabia","_hash_id":"84d7ffe49e6bde194fc995223bac848b","url":│            │    │                              │                                         │                      │               │                                 │..." }                                                                │            │
│"https://www.ncbi.nlm.nih.gov/pmc/articles/PMC35282/"}                │            │    │                              │                                         │                      │               │                                 │                                                                      │            │
│                                                                      │            │    │                              │                                         │                      │               │                                 │                                                                      │            │
├──────────────────────────────────────────────────────────────────────┼────────────┼────┼──────────────────────────────┼─────────────────────────────────────────┼──────────────────────┼───────────────┼─────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────────┤
│{"cord_uid":"ug7v899j","cord19-fulltext_hash":"d1aafb70c066a2068b02786│["Paper"]   │{}  │"PAPER_HAS_BODYTEXTCOLLECTION"│{"id":"c6c001198a1ca7136a0c476b7723d9bf"}│["BodyTextCollection"]│{"position":1} │"BODYTEXTCOLLECTION_HAS_BODYTEXT"│{"section":"Institution and patient population","_hash_id":"bfbe0ce7b5│["BodyText"]│
│f8929fd9c900897fb","journal":"BMC Infect Dis","publish_time":"2001-07-│            │    │                              │                                         │                      │               │                                 │2ce5eafe590b0697cf7fb4","text":"KAUH is a tertiary care teaching hospi│            │
│04","source":"PMC","title":"Clinical features of culture-proven Mycopl│            │    │                              │                                         │                      │               │                                 │tal with a bed capacity of 265 beds and annual admissions of 18000 to │            │
│asma pneumoniae infections at King Abdulaziz University Hospital, Jedd│            │    │                              │                                         │                      │               │                                 │19000 patients. Patients with M. pneumoniae positive cultures from res│            │
│ah, Saudi Arabia","_hash_id":"84d7ffe49e6bde194fc995223bac848b","url":│            │    │                              │                                         │                      │               │                                 │piratory specimens were identified over a 24-months" period from Janua│            │
│"https://www.ncbi.nlm.nih.gov/pmc/articles/PMC35282/"}                │            │    │                              │                                         │                      │               │                                 │ry, 1997 through December, 1998 for this review."}                    │            │
├──────────────────────────────────────────────────────────────────────┼────────────┼────┼──────────────────────────────┼─────────────────────────────────────────┼──────────────────────┼───────────────┼─────────────────────────────────┼──────────────────────────────────────────────────────────────────────┼────────────┤
...
```

So the results show us that (in the metamodel language (LPG)):
- The paper (s0)
    - has some properties (key/value pairs) including the paper's title, the journal name it was published in, etc.
    - has the label "Paper"
    - has a relationship (p0) to some body text collection (s)
        - the relationship (p0) is of type "PAPER_HAS_BODYTEXTCOLLECTION"
- The body text collection (s)
    - has a property: an identifier
    - has the label "BodyTextCollection"
    - has a relationship (p) to some body text (o)
        - the relationship (p)
            - is of type "BODYTEXTCOLLECTION_HAS_BODYTEXT"
            - has a property: a position (in the paper)
- The body text (o)
    - has some properties including the section name, and the actual text


TODO is it more clear to talk about choices or options? or a choice with options?

The implementaion choices I am refering to are the choices about where to put data.
I call these "implementation" choices because a storage location is often an implementation choice.

With LPG you can put data in:
- a node property         (any key, any value)
- a node label            (single key "label", any value)
- a relationship property (any key, any value)
- a relationship type     (single key "type", any value)

That is 4 options and I think that is 3 options too many.

If you want your data to participate in the "extended graph" (which includes any other graph you might care about later) then you want most of your choices to be data modeling choices not implementation choices.
As your graph participates in the "extended graph" you don't want to your data modeling choice (saying the paper is of type "Paper") to be undermined by the fact that you chose to implement that assertion with a node label while somewhere else in the extended graph a similar assertion was implemented with a node property even though the data modeling agreed on the type "Paper."


When you make the same data modeling choice but a difference implementation choice you lose query uniformity.
Let's hold the data modeling choice at: "label" means "type of" and "Paper" is the kind of thing we are talking about and step through the implementation options' corresponding Cypher query:
```
match (s:Paper)-[p]-(o) return s,p,o
match (s {label: "Paper"})-[p]-(o) return s,p,o
match (s)-[p:label]-(o:Paper) return s,p,o
match (s)-[p:label]-(o {label: "Paper"}) return s,p,o
<!-- match (s)-[p {label: "Paper"}]-(o) return s,p,o -->
```



If want your graph to align with any other graph they must agree in the options they selected for data modeling choices and in the options they chose for implementation choices.
The data modeling choices are hard enough so why complicate things by adding implementation choices?
You can prevent implementation choices from impairing data integration by not making any (implementation choices) by using RDF.
You can't do that with LPG; you must make implementation choices.


Now let's look at the implementation choices that were made in [this](https://github.com/covidgraph/data_cord19) project and see what the cost of those choices is.

1) Assertion: The paper is a type of "Paper"
    - Implementation: node label "Paper"

2) Assertion: The paper was published in a specific journal
    - Implementation:  node property key/value pair: "journal", "BMC Infect Dis"

3) Assertion: The paper has a collection of text in the body
    - Implementation:  relationship type "PAPER_HAS_BODYTEXTCOLLECTION" with node label "BodyTextCollection"

4) Assertion: The collection of text in the body has body text in 0th (and 1st, and 2nd, etc.) position in the paper
    - Implementation:  relationship property key/value pair: "position", 0     (1, 2, etc., etc.)

5) Assertion: the body text in position 0 has the literal text "Mycoplasma pneumoniae is a common cause..." 
    - Implementation: node property key/value pair: "text", "Mycoplasma pneumoniae is a common cause..." 


Because these 4 different implementation choices were made the cost is that in order to query the graph you need to discover which choice was made for each assertion.


But notice how, in natural language, each assertion has the same structure: subject, predicate, object

```
---------------------------------------------------------------------------
|    |    subject                 |  predicate           |    object
|--------------------------------------------------------------------------------
|1   |   the paper                | is of type           | "Paper"
|2   |   the paper                | was published in     | "BMC Infect Dis"
|3   |   the paper                | has a collection     | the body text collection  
|4   |   the body text collection | has text in position | 0
|5   |   text in position 0       | has literal text     | "Mycoplasma pneumoniae is a common cause..." 
-------------------------------------------------------------------------------
```


So you can use a single implementation option (subject, predicate, object) then you only have to make data modeling choices.
Also if you use a single implementation option, the graph query writer wouldn't need to discover which implementation choices were made.

This single implementation option is what RDF does.
With RDF there is only one query flavor to find things that are of type "Paper":
```
select * where {?s :type :Paper}
```

With RDF, if we allow different data modeling options then query content changes but not structure:
```
select * where {?s :type :Paper}
select * where {?s :typeOf :Paper}
select * where {?s :type :JournalArticle}
select * where {?s :typeOf :JournalArticle}
```

But with LPG, if we allow different data modeling options then query content changes *and* the structure can change to (because there are different implementation options):
```
match (s:Paper)-[p]-(o) return s,p,o
match (s {type: "Paper"})-[p]-(o) return s,p,o
match (s)-[p:type]-(o:Paper) return s,p,o
match (s)-[p:type]-(o {type: "Paper"}) return s,p,o

match (s:Paper)-[p]-(o) return s,p,o
match (s {typeOf: "Paper"})-[p]-(o) return s,p,o
match (s)-[p:typeOf]-(o:Paper) return s,p,o
match (s)-[p:typeOf]-(o {typeOf: "Paper"}) return s,p,o

match (s:JournalArticle)-[p]-(o) return s,p,o
match (s {type: "JournalArticle"})-[p]-(o) return s,p,o
match (s)-[p:type]-(o:JournalArticle) return s,p,o
match (s)-[p:type]-(o {type: "JournalArticle"}) return s,p,o

match (s:JournalArticle)-[p]-(o) return s,p,o
match (s {typeOf: "JournalArticle"})-[p]-(o) return s,p,o
match (s)-[p:typeOf]-(o:JournalArticle) return s,p,o
match (s)-[p:typeOf]-(o {typeOf: "JournalArticle"}) return s,p,o
```
