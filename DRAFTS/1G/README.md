# Graph? Yes! Which one? RDF!


AWS Neptune supports LPG and RDF but they are separate sides of Neptune -- that is, LPG and RDF aren't interoperable.
Some key AWS Neptune team members are [thinking](https://www.lassila.org/publications/2021/scg2021-lassila+etal.pdf) about LPG and RDF graph interoperability in what they call "one graph" (1G).
The [idea](https://www.lassila.org/publications/2021/scg2021-lassila+etal-preso.pdf) is that 1G is comprehensive enough to support LPG and RDF metamodels at the same time.

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
Clearly we need graphs to do cool stuff.




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


### domain modeling

We have a finite number of choices we can make per day.

Kurt Cagle [notes](https://www.bbntimes.com/technology/the-pros-and-cons-of-rdf-star-and-sparql-star) "That RDF is not used as much tends to come down to the fact that most developers prefer to model their domain as little as possible."

Software developers certainly model their logical and physical schema as needed, but modeling of the conceptual schema (the domain) is given minimal attention.  

That developers prefer to model their domain as little as possible causes things like this:

> Note that the choice of LPG can also happen when RDF is dismissed out of hand because it is viewed as complex and "academic".

The use of LPG makes it more natural to skip thoughtful domain modeling (which is the "academic" part) .
I say that because with LPG there are many [implementation choices](TODO link to section) to make and domain modeling choices.
Whereas, with RDF there are no implementation choices (there are only domain modeling choices).
Because LPG allows software developers to spend their daily budget of decisions on implementation choices the domain modeling can get the attention scraps.


> Regardless of what the reasons, we believe that the (forced) choice of graph models slows the adoption of graphs because it creates confusion and segmentation in the graph database space.

I agree with that but I am not sure if the optimal way to un-segment the graph database space is to work hard making a model (the "1G" model) to accommodate a metamodel that makes it more natural to skip thoughtful domain modeling.
After AWS Neptune lands all the indecisive customers, the customers will still eventually have to get onto the important and tricky business of domain modeling so why not just have the customers start now.




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


By putting information into the structure of the graph and by using a Pareto vocabulary (ontology) you can do the following:

A) Represent secondary or tertiary facts about previously stated facts.

```
# Fred witnessed Alice meeting Bob

:event-045 :hasParticipation [ a :Participation ;
                                  :hasRole :Observer ;
                                  :hasParticipant :Fred ] .
```
Also see [a.ttl](./a.ttl) for tertiary fact representation.


B) Generalize to other events with the same vocabulary.

See [a.ttl](./a.ttl) for representations of film productions and rocket launches using the same vocabulary.
You'll notice how representations don't just bottom out in strings.
"Things not strings" is a common refrain in the RDF world.



Put another [way](https://www.bbntimes.com/technology/the-pros-and-cons-of-rdf-star-and-sparql-star): "RDF-star [(statements about statements)] should not be used to solve [domain] modeling deficiencies."
Kurt Cagle also notes "do you need RDF-star? From the annotational standpoint, quite possibly, as it provides a means of tracking volatile property and relationship value changes over time."
While you could, I think I might instead use something like a triplestore with immutable state (e.g. [asami](https://github.com/threatgrid/asami)) when I have a volatile named graph.
In general, however, I would keep named graphs read-only as often as possible.
No, nevermind on that. ?
Most data is read-only-flavored anyway because as things move from the present into the past their volatility is over. 


## implementation choices

With LPG you can put representations in:
- a node property         (any key, any value)
- a node label            (single key "label", any value)
- a relationship property (any key, any value)
- a relationship type     (single key "type", any value)

That is 4 options and I think that is 3 options too many.
See [LPGs_many_implementation_choices](./LPGs_many_implementation_choices.md) for an expansion on that.

