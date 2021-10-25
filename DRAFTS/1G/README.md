# Graph? Yes! Which one? RDF!


AWS Neptune supports LPG and RDF but they are separate sides of Neptune -- that is, LPG and RDF aren't interoperable.
Some key AWS Neptune team members are thinking about LPG and RDF graph interoperability in what they call "one graph" (1G).
The idea is that 1G is comprehensive enough to support LPG and RDF metamodels at the same time.

You can understand why they'd want to do that.
If they can appeal to all the customers that can't easily decided between LPG and RDF they'd appeal to many more customers.

Deciding between LPG and RDF is a matter of deciding between today and many tomorrows, respectively.



## Why Graphs

When a data scientist is looking at some tabular data she gets a semantic network (a graph) in her head.
```
----------------------------------------------------------------
|    where                 |  who               |    what
-------------------------------------------------------------------
|   "library"              | "Colonel Mustard"  | "candlestick"
|   "conservatory"         | "Mrs. Peacock"     | "lead pipe"
```

She doesn't just mentally interact with the string "library."
She mentally interacts with the thing [library](https://www.wikidata.org/wiki/Q29843656).
The thing library is a specific kind of room.
It is used to store books.
It is related to [library](https://www.wikidata.org/wiki/Q7075) the institution.

So graphs aren't magical.
They are just representations of what happens in our heads when we interact with data.
And if you put (explicitly) that cool stuff that happens in our heads inside some computers you can use that cool stuff programmatically.
Clearly we need them to do cool stuff.


## they want to use RDF-star as the 1G metamodel

The 1G data model they are thinking about is basically RDF where each triple has an internal identifier.
TODO which is interesting -- RDF as the general metamodel...
This is my cheapest observation.
The observation that the "one graph" metamodel looks more like RDF than LPG.




## today's needs (LPG)                  #  vs. many of tomorrow's needs (RDF) (i need this section somewhere )

I find myself looking for reasons to solve [the general problem](https://xkcd.com/974/) but not everyone does.
I'm glad we have a mixture of reason seekers.

> Making a good choice between the two technology stacks is complex and requires a balanced consideration of data modeling aspects, query language features, and their adequacy for current and future use cases.

When it comes to future use cases, in my experience, all roads lead to (data) integration.
RDF/SPARQL is specifically designed with data integration in mind (global URIs, federated queries, a single representation pattern (the triple), etc.).

> ... we often see information architects prefer the features of the RDF model because of a good fit with use cases for data alignment, master data management, and data exchange.

To put it not so carefully, I would say that LPG seems to be specifically designed with the following in mind:
- introducing graphs to software developers (who know json)
    - and not strongly encouraging them to model their data thoughtfully
- supporting path traversal well

In other words: LPG was designed to support "[point solutions](https://allegrograph.com/why-young-developers-dont-get-knowledge-graphs/)."


> Software developers often choose an LPG language because they find it more natural and more "compatible" with their programming paradigm.

Making a decision based on what your team is comfortable with (LPG) is about today.


### domain modeling vs. implementation choices

We have a finite number of choices we can make per day.

Kurt Cagle [notes](https://www.bbntimes.com/technology/the-pros-and-cons-of-rdf-star-and-sparql-star) "That RDF is not used as much tends to come down to the fact that most developers prefer to model their domain as little as possible."

Software developers certainly model their logical and physical schema as needed, but modeling of the conceptual schema (the domain) is given minimal attention.  

That developers prefer to model their domain as little as possible causes things like this:

> Note that the choice of LPG can also happen when RDF is dismissed out of hand because it is viewed as complex and "academic".

The use of LPG makes it more natural to skip thoughtful domain modeling (which is the "academic" part) .
I say that because with LPG there are many implementation choices to make and domain modeling choices.
Whereas, with RDF there are no implementation choices (there are only domain modeling choices).
Because LPG allows software developers to spend their daily budget of decisions on implementation choices the domain modeling can get the attention scraps.


> Regardless of what the reasons, we believe that the (forced) choice of graph models slows the adoption of graphs because it creates confusion and segmentation in the graph database space.

I agree with that but I am not sure if the optimal way to un-segment the graph database space is to work hard making a model (the "1G" model) to accommodate a metamodel that makes it more natural to skip thoughtful domain modeling.




## Statements About Statements


A big part of LPG is the ability to make statements about statements (with relationship properties).
But the ability to make statements about statements encourages you to skip more thoughtful domain modeling.
And it is the thoughtful domain modeling that enables data integration and it allows query writers to explore generalizations such as analogy.

Let's look at what thoughtful domain modeling looks like.

An example from the 1G paper is:
```
<< :Alice :knows :Bob >> :since "2020-01-01"^^xsd:date . 
```
Which is here represented in RDF-star but which is also easy to represent LPG (for example with a relationship property).

Maybe you think that statement is easy to read and work with.
It seems to say something like: "Alice has known Bob since 2020."

But my ontologist colleagues say something like "I probably wouldn't reify that state of affairs like that."

The RDF representation I'll show is a little more wordy than the rdf-star version but it offers data integration advantages.
The data integration advantages of RDF with thoughtful domain modeling arise from the fact that relationships (like `:knows`) don't have to be merely a single edge type, instead you can decompose "knowing" into the structure of the RDF graph like the following:

```
# alice knows bob and we know how (a conversation) and since when (day granularity)
:Alice a :Human .
:Bob a :Human .

:event-045 a :Conversation , :Introduction ;
           gist:hasActualStart "2020-01-01"^^xsd:date ;
           :hasParticipation [ a :Participation ;
                                   :hasRole :Interlocutor ;
                                   :hasParticipant :Bob ] ;
           :hasParticipation [ a :Participation ;
                                   :hasRole :Interlocutor ;
                                   :hasParticipant :Alice ] .
```
That is, knowing (as defined here) consists of:
- awareness of another (`:Introduction`)
    - some historical event (`has:hasActualStart`) such as a (`:Conversation`)
- acts of participation (`:Participation`)
    - with roles (such as `:Interlocutor`)
    - and participants

(see [a.ttl](./a.ttl) for more context)


The following advantages come from putting information into the structure of the graph and by using a pareto vocabulary.
By putting information into the structure of the graph and (by using a Pareto vocabulary (ontology)) you can do the following:

A) Represent the fact that people witnessed the introduction.

```
# Fred witnessed Alice meeting Bob

:event-045 :hasParticipation [ a :Participation ;
                                  :hasRole :Observer ;
                                  :hasParticipant :Fred ] .
```

B) Generalize to other similar events:

See [a.ttl](./a.ttl) for representations of film productions and rocket launches using the same vocabulary.

In [a.ttl](./a.ttl) you'll notice how representations don't just bottom out in strings.
"Things not strings" is a common refrain in the RDF world.



Put another [way](https://www.bbntimes.com/technology/the-pros-and-cons-of-rdf-star-and-sparql-star): "RDF-star [(statements about statements)] should not be used to solve [domain] modeling deficiencies."
Kurt Cagle also notes "do you need RDF-star? From the annotational standpoint, quite possibly, as it provides a means of tracking volatile property and relationship value changes over time."
While you could, I think I might instead use something like a triplestore with immutable state (e.g. [asami](https://github.com/threatgrid/asami)) when I have a volatile named graph.
In general, however, I would keep named graphs read-only as often as possible.
No, nevermind on that. ?
Most data is read-only-flavored anyway because as things move from the present into the past their volatility is over. 








## Domain modeling choices vs. implementation choices

https://www.lassila.org/publications/2021/scg2021-lassila+etal.pdf
https://www.lassila.org/publications/2021/scg2021-lassila+etal-preso.pdf

I was reading the 1G paper...

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
