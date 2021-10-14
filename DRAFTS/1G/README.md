# discussion on 1G 


I was reading the 1G paper...

As a metamodel, LPG (labeled property graph) has too many options on where to say things.
That means to use an LPG representation you must make implementation choices that aren't data modeling choices.

In RDF you don't have those implementation choices to make.

For example, let's say we want to talk about this paper (and its sections).
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC35282/

We'll first use an LPG representation (https://github.com/covidgraph/data_cord19) then an RDF representation.


The following Cypher query:
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


The implementaion choices I am refering to are the choices about where to put data.
With LPG you can put data in:
- a node property         (any key, any value)
- a node label            (single key "label", any value)
- a relationship property (any key, any value)
- a relationship type     (single key "type", any value)

I think that is 3 choices too many.
If you want your data to participate in the "extended graph" then you want most of you choices to be data modeling choices not implementation choices.

Now let's look at the implementation choices that were made and see what the cost of those choices is.

A) Assertion: The paper is a type of "Paper"

    - Implementation: node label "Paper"

B) Assertion: The paper was published in a specific journal
    - Implementation:  node property key/value pair: "journal", "BMC Infect Dis"

C) Assertion: The paper has a collection of text in the body
    - Implementation:  relationship type "PAPER_HAS_BODYTEXTCOLLECTION" with node label "BodyTextCollection"

D) Assertion: The collection of text in the body has body text in 0th (and 1st, and 2nd, etc.) position in the paper
    - Implementation:  relationship property key/value pair: "position", 0     (1, 2, etc., etc.)

D1) Assertion: the body text in position 0 has the literal text "Mycoplasma pneumoniae is a common cause..." 
    - Implementation: node property key/value pair: "text", "Mycoplasma pneumoniae is a common cause..." 


Because these 4 different implementation choices were made the cost is that in order to query the graph you need to discover which choice was made for each assertion.
TODO show Cypher differences.


But notice how, in natural language, each assertion has the same structure: subject, predicate, object

```
---------------------------------------------------------------------------
|   |    subject                 |  predicate           |    object
|--------------------------------------------------------------------------------
|A  |   the paper                | is of type           | Paper
|B  |   the paper                | was published in     | BMC Infect Dis
|C  |   the paper                | has a collection     | the body text collection  
|D  |   the body text collection | has text in position | 0
|D1 |   text in position 0       | has literal text     | "Mycoplasma pneumoniae is a common cause..." 
----------------------------------------------------------------------------------
```


If instead all of your choices were data modeling choices you could use the single common structure (subject, predicate, object) and then the graph query writer wouldn't need to discover which implementation choices were made.
