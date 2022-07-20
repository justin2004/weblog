# Fused Edges
By fused edge I mean using a single edge as a shortcut for multiple edges.

## What

In a graph database fused edges occur when the domain modeler uses a single edge when a node and two edges would be more thoughtful.
To me a fused edges feels like running an interstate through an area of interest and not putting an exit nearby.

Here is an example of fused edges: 

![fused edges](media/fused_edges.png)

And here is what those fused edges look like in turtle:
```ttl
:event01 :venueName "Olive Garden" .
```

You can see the fusion of edges in the name of the edge usually: there is a "venue" and there is a "name."

Here is a more thoughtful representation
![articulating edges](media/articulating_edges.png)


with an additional point of articulation.
```ttl
:event01 :occursIn :venue01 .
:venue01 :name "Olive Garden" .
```

Here is another common pair of fused edges:  

```ttl
:person02 :mothersMaidenName "Smith" .
```

vs.

```ttl
:person02 :hasMother :person01 .
:person01 :maidenName "Smith" .
```


## Why
I can think of three (two I heard other people say) reasons why fused edges might be used.

1) [Your source data may not have details about the venue other than its name.](https://twitter.com/valexiev1/status/1509176909741109258?s=20&t=SBnKJ9_TXmVwgRgvfz2aLg)

2) ["you get better #findability with dedicated properties"](https://twitter.com/salgo60/status/1516753692728471559?s=20&t=sYoBxBlyLxBg0XWUqQ9fNQ)

3) Fewer nodes in a graph likely means fewer hardware resources are required.

Let me attempt to persuade you that you should mostly ignore those reasons to use fused edges.

(1) 

One of the ideas of the semantic web is AAA: Anyone can say Anything about Any topic.

It is hard for someone to say something about the venue (perhaps its address, current owner, hours of operation) if no node exists in the graph for it.
With the fused edge, if someone does come along later and they want to express the venue's address it is not a straight forward update.
You'd have to make a new venue node, find the event node in the graph, find all the edges expressing facts about the venue and move them to the new venue node, then connect the event to the new venue node.
Finding all the edges hanging off of the event that express facts about the venue will likely be a manual effort -- there probably won't be clever data for the machine to use that says `:mothersMaidenName` is not a direct attribute of the subject but rather a direct attribute of the subject's mother. 
At worst, fused edges encourage the use of additional fused edges.
If you don't have a node to reference then a modeler might make more fused edges in order to express additional information.

(2) 

Giving a shortcut a name can be valuable, yes.

But I think if you use a shortcut the thing the shortcut hides should also be available.
But if you use fused edges that is not available; there is only the shortcut.

In SPARQL you can use shortcuts: property paths.
In OWL you can define those shortcuts: property chains.

In a SPARQL query you could just do
```sparql
?person :hasMother/:maidenName ?persons_mother_maidenname .
```

Or you could define that in OWL
```ttl
:mothersMaidenName  owl:propertyChainAxiom  ( :hasMother  :maidenName ) .
```
And if you have an OWL 2 reasoner active you can just query using the shortcut:
```sparql
?person :mothersMaidenName ?persons_mother_maidenname .
```

(3)

I don't have much to say about this.
I can put a billion triples in a triplestore on my laptop and query durations will probably be acceptable.
If I put 100 billion triples on my laptop query durations might not be acceptable.
Still I think I would rather consider partitioning the data and using SPARQL query federation rather than fusing edges together to reduce resource requirements. 
I say that because I reach for semantic web technologies when I think serendipity (link to Ora) would be valuable.

Fused edges and serendipity don't go together.
Fused edges are about the use cases you know about and the data you currently have.
Graphs with thoughtful points of articulation are about the use cases you know about, those you discover tomorrow, and about potential data.
Points of articulation in a graph suggest enrichment opportunities and new questions.




## Schema.org

Schema.org loves to use fused edges.

If you run this SPARQL query against `schema.ttl`:
```sparql
PREFIX  schema: <https://schema.org/>
PREFIX  rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT *
WHERE
  { graph ?g {
      ?s rdfs:comment ?com .
      {
          GRAPH ?g
          { ?s  schema:rangeIncludes  schema:URL
            MINUS
              { ?s  schema:rangeIncludes  ?o
                FILTER ( ?o != schema:URL )
              }
          }
      }
  }
}
```
That query finds properties that are intended to have only instances of schema:URL in the object position.

You get these bindings:

|s                                    |com                                                                                                                                        |g                                    |
|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------|
|https://schema\.org/sameAs           |URL of a reference Web page that unambiguously indicates the item's identity\. E\.g\. the URL of the item's Wikipedia page, Wikidata entry, or official website\.|http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/additionalType   |An additional type for the item, typically used for adding more specific types from external vocabularies in microdata syntax\. This is a relationship between something and a class that the thing is in\. In RDFa syntax, it is better to use the native RDFa syntax \- the 'typeof' attribute \- for multiple types\. Schema\.org tools may have only weaker understanding of extra types, in particular those defined externally\.|http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/codeRepository   |Link to the repository where the un\-compiled, human readable code and related code is located \(SVN, github, CodePlex\)\.                 |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/contentUrl       |Actual bytes of the media object, for example the image file or video file\.                                                               |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/discussionUrl    |A link to the page containing the comments of the CreativeWork\.                                                                           |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/downloadUrl      |If the file can be downloaded, URL to download the binary\.                                                                                |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/embedUrl         |A URL pointing to a player for a specific video\. In general, this is the information in the \`\`\`src\`\`\` element of an \`\`\`embed\`\`\` tag and should not be the same as the content of the \`\`\`loc\`\`\` tag\.|http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/installUrl       |URL at which the app may be installed, if different from the URL of the item\.                                                             |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/map              |A URL to a map of the place\.                                                                                                              |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/maps             |A URL to a map of the place\.                                                                                                              |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/paymentUrl       |The URL for sending a payment\.                                                                                                            |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/relatedLink      |A link related to this web page, for example to other related web pages\.                                                                  |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/replyToUrl       |The URL at which a reply may be posted to the specified UserComment\.                                                                      |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/serviceUrl       |The website to access the service\.                                                                                                        |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/significantLinks |The most significant URLs on the page\. Typically, these are the non\-navigation links that are clicked on the most\.                      |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/significantLink  |One of the more significant URLs on the page\. Typically, these are the non\-navigation links that are clicked on the most\.               |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/targetUrl        |The URL of a node in an established educational framework\.                                                                                |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/thumbnailUrl     |A thumbnail image relevant to the Thing\.                                                                                                  |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/trackingUrl      |Tracking url for the parcel delivery\.                                                                                                     |http://127\.0\.0\.1:3030/three/data/g1|
|https://schema\.org/url              |URL of the item\.                                                                                                                          |http://127\.0\.0\.1:3030/three/data/g1|

You can see that most of those object properties are fused edges.
e.g.

schema:paymentUrl fuses together `hasPayment` and `url`

schema:trackingUrl fuses together `hasTracking` and `url`

schema:codeRepository fuses together `hasCodeRepository` and `url`
etc.

If you run that same query with `schema:Place` you can see many fused properties as well.


That's the end of this blog post.
Please consider not using fused edges and instead use an ontology that encourages the thoughtful use of points (nodes) of articulation!



## Appendix



schema.org way (fused edges)
```ttl
[ a schema:CreativeWork ;
  a wd:Q1886349 ; # Logo 
  schema:url  "https://i.imgur.com/46JjPLl.jpg" ;
  rdfs:label "Shipwreck Cafe Logo" ;
  schema:discussionUrl  "https://gist.github.com/justin2004/183add3d617105cc9cc7cee013d44198" ]
                      
```

points of articulation way
```ttl
[ a schema:UserComments ;
  schema:url "https://gist.github.com/justin2004/183add3d617105cc9cc7cee013d44198" ; 
  schema:discusses [ a schema:CreativeWork ;
                     a wd:Q1886349 ; # Logo 
                     rdfs:label "Shipwreck Cafe Logo" ;
                     schema:url  "https://i.imgur.com/46JjPLl.jpg"
                   ]
]
wd:Q113149564 schema:logo "https://i.imgur.com/46JjPLl.jpg" .
```

`schema:discussionUrl` is really a shorthand for the property path: `(^schema:discusses)/schema:url`.
So it is 2 edges fused together in such a way that you can't reference the node in the middle: the discussion itself.
If you can't reference the node in the middle (the discussion itself) you can't say when it started, when it ended, 
who the participants were, etc.

