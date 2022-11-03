# Interfaces and Interactions

## Too Much Specificity And Not Enough Play

<!-- # load file:///mnt/fruit/a.ttl into named graph on fuseki running on localhost:3030 dataset "apples" -->
<!-- # TODO get curl command to upload into that namedgraph -->

I recently saw this tweet and it reminded me about something I've wanted to think and talk about.

-tweet-

He continues

> configuration management has not had the attention enjoyed by academic research for languages and networking, as well as language and networking innovations in industry.

> I don’t think a “configuration language” is the solution, nor is a domain specific language / library (DSL).

I tend to agree.
I think perhaps we should explore more loosy-goosey, declarative approaches.
That is, systems with more play (as in "scope or freedom to act or operate").

I'd like to see more semantic messages that convey the spirit rather than the letter.
When you can't forsee all the consequences of the letter then that's when the spirit can help.

That's what I'd like to talk and think about in this post.

Let's see an example of such a loosy-goosey semantic message.

## Semantic Messages

I'm writing another blog post on what "semantic" means in the semantic web.
I'll put a link here once I am done but in the mean time think of "semantic" as getting different things (people and machines) to see eye to eye.
Yes, a tall order.

The hypothetical situation is that I have Apache Jena Fuseki (a database for RDF) running on my local machine.
There is a [software agent (semantic web style)](https://www-sop.inria.fr/acacia/cours/essi2006/Scientific%20American_%20Feature%20Article_%20The%20Semantic%20Web_%20May%202001.pdf) running on my local machine that knows how to interact with Apache Jena Fuseki.
I am running a software agent (semantic web style) to whom I make requests.

I have a file on my machine that I want to load into a dataset on the Apache Jena Fuseki instance.
I type this request to my agent "load /mnt/toys/gifts.ttl in Apache Jena Fuseki at dataset 'gifts' on 25 Dec early in the morning."

My agent produces the following RDF (or I do by some other means):
TODO

### Side Note

You might notice that I've used the URI of an RDF named graph in the place where a resource would typically be expected.
With this blog post I am also thinking about using named graphs to represent the content of goals (`gist:Goal`).
Really a named graph could represent the content of many different types of things.

RDF-star is designed to allow one to treat a single triple as a resource that you can refer to but I think RDF named graphs already allow that and the more general case of multiple triples.
So far I think RDF-star is, at best, unnecessary and at worst it encourages domain modeling that is based on annotating statements rather than expressing things and relationships in the world.


## Back to the semantic message example

My agent then puts that RDF onto the semantic message bus (the bus where agents listen for and send RDF) on my local machine.
The agent that governs Apache Jena Fuseki sees the RDF and recognizes that it knows how to handle the request.

The agent that inteprets that RDF needs to know some things.

It needs to know things like:
- that it is capable of and allowed to handle requests to load data into the Apache Jena Fuseki running on localhost at port 3030
- how to use GSP or some other programmatic method to load data into Fuseki
  - how to reference a dataset or optionally create one if the desired on does not exist
- how to delay the execution of this (since the `gist:plannedStartDateTime` is in the future)

Fuseki's agent can't be too finicky about interpreting the RDF.

The spirit of the RDF is pretty clear "early in the morning on December 25th find the file /mnt/toys/gifts.ttl and load it into the dataset 'gifts' on the Apache Jena Fuseki server running on localhost at port 3030."

If the agent saw this message or a similar message but it knew the message content wasn't sufficient for it to do anything then it would reply, by putting RDF onto the semantic message bus, with perhaps a helpful minimal message example.
There could be a back and forth between my agent and the agent governing Apache Jena Fuseki as my agent figures out how to schedule the ingestion of that data.

But this time Fuseki's agent knew what to do.
It runs the following command:

at 25 dec 1am <<~
curl blah
~

## Closing

I haven't sketched everything out.
For example, what if the command fails on 25 Dec because the file is missing?
I'd expect the Fuseki agent to tell my agent.
Also maybe my agent could periodically check that the file is accessible and report back to me if it isn't.

Anyway, I imagine you get the idea.

I do think a requirement of semantic message bus is that all agents must have the same world view and speak the same langauge.
I used the [gist upper ontology](https://github.com/semanticarts/gist) for my example.

