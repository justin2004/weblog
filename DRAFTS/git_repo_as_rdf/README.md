# Git Repositories as RDF Graphs

## Motivation

A while back cURL's creator, Daniel Stenberg, tweeted some stats on cURL's git repository.

![cURL tweet](media/curl_tweet.png)

[tweet](https://twitter.com/bagder/status/1507002666488000514?s=20&t=ZPZXYELS73inW1HuhyIMlw)

I have a pretty good idea about how he answered those questions.
I bet he used some tools like sed, awk, and grep.
I like thoes those tools and use them daily but I wondered what it would be like to answer those questions semantic web style.

## What

In order to answer questions semantic web style you first have to find or make some thoughtful RDF.
I say "thoughtful" because it is possible to use the semantic web stack (RDF/SPARQL/OWL/SHACL, etc.) without doing much domain modeling.

In our case we can easily get some structured data.
Here is a git commit I just made:

```
commit e3c3d94d1748316dce192e76dca0d2baa82e9c27
Author: Justin <justin2004@hotmail.com>
Date:   Tue Aug 23 07:24:29 2022 -0400

    some creatures

    added four creatures

diff --git a/some.txt b/some.txt
new file mode 100644
index 0000000..882149f
--- /dev/null
+++ b/some.txt
@@ -0,0 +1,4 @@
+some pig.
+some rat.
+some goose.
+some spider.
```

Notice how compact that representation is.
If you work with git much you probably recognize what most of that is.
But the semantic web isn't about just allowing you to work with data you already know about.
So that means we need to unpack this compact application-centric representation into a [data-centric](http://www.datacentricmanifesto.org/) representation.

It is a fine representation for the `patch` tool but doesn't really check any of [these boxes](https://youtu.be/f9wautaqWUs?t=1116):

![Ora slide](media/ora_slide.jpg)



Ok, I've transformed that representation into a thoughtful RDF graph... let's take a look:


![as visual graph](media/first.png)

You'll notice that...

TODO get prefixes

```turtle
<http://example.com/commit/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=e3c3d94>
        <https://ontologies.semanticarts.com/gist/hasPart>
                <http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=e3c3d94;hunk=e889faa5-4999-40fd-b6fa-49fc14791d3a> .

<http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=e3c3d94;hunk=e889faa5-4999-40fd-b6fa-49fc14791d3a>
        a       <http://www.wikidata.org/entity/Q113509427> ;
        <https://ontologies.semanticarts.com/gist/produces>
                [ a       <http://www.wikidata.org/entity/Q113515824> ;
                  <http://example.com/containedTextContainer>
                          [ <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1>
                                    "some pig." ;
                            <http://www.w3.org/1999/02/22-rdf-syntax-ns#_2>
                                    "some rat." ;
                            <http://www.w3.org/1999/02/22-rdf-syntax-ns#_3>
                                    "some goose." ;
                            <http://www.w3.org/1999/02/22-rdf-syntax-ns#_4>
                                    "some spider."
                          ] ;
                  <https://ontologies.semanticarts.com/gist/hasMagnitude>
                          [ <https://ontologies.semanticarts.com/gist/hasUnitOfMeasure>
                                    <https://ontologies.semanticarts.com/gist/_each> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    4
                          ] ;
                  <https://ontologies.semanticarts.com/gist/identifiedBy>
                          [ a       <http://www.wikidata.org/entity/Q6553274> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/occursIn>
                          [ a       <http://www.wikidata.org/entity/Q86920> ;
                            <https://ontologies.semanticarts.com/gist/name>
                                    "some.txt"
                          ]
                ] .

<http://example.com/commit/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=e3c3d94>
        a       <http://www.wikidata.org/entity/Q20058545> ;
        <http://purl.org/dc/terms/creator>
                [ <https://ontologies.semanticarts.com/gist/name>
                          "Justin" ;
                  <https://schema.org/email>  "justin2004@hotmail.com"
                ] ;
        <http://purl.org/dc/terms/subject>
                [ <http://purl.org/dc/terms/description>
                          "added four creatures" ;
                  <http://purl.org/dc/terms/title>
                          "some creatures"
                ] ;
        <https://ontologies.semanticarts.com/gist/atDateTime>
                "2022-08-23T07:24:29-04:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
        <https://ontologies.semanticarts.com/gist/isIdentifiedBy>
                [ <https://ontologies.semanticarts.com/gist/uniqueText>
                          "e3c3d94" ] .
```



```
commit 0e40522a20754fc82d751000eae710b5ad09e2f3
Author: Justin <justin2004@hotmail.com>
Date:   Tue Aug 23 07:25:26 2022 -0400

    capitalization

    caps on pig and spider.

diff --git a/some.txt b/some.txt
index 882149f..c4ef5c5 100644
--- a/some.txt
+++ b/some.txt
@@ -1,4 +1,4 @@
-some pig.
+some Pig.
 some rat.
 some goose.
-some spider.
+some Spider.
```


```turtle
<http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522;hunk=f2f312bb-49fb-48a1-a62e-323c0519b333>
        a       <http://www.wikidata.org/entity/Q113509427> ;
        <https://ontologies.semanticarts.com/gist/affects>
                [ a       <http://www.wikidata.org/entity/Q113515824> ;
                  <http://example.com/containedTextContainer>
                          [ <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1>
                                    "some spider." ] ;
                  <https://ontologies.semanticarts.com/gist/hasMagnitude>
                          [ <https://ontologies.semanticarts.com/gist/hasUnitOfMeasure>
                                    <https://ontologies.semanticarts.com/gist/_each> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/identifiedBy>
                          [ a       <http://www.wikidata.org/entity/Q6553274> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    4
                          ] ;
                  <https://ontologies.semanticarts.com/gist/occursIn>
                          [ a       <http://www.wikidata.org/entity/Q86920> ;
                            <https://ontologies.semanticarts.com/gist/name>
                                    "some.txt"
                          ]
                ] ;
        <https://ontologies.semanticarts.com/gist/produces>
                [ a       <http://www.wikidata.org/entity/Q113515824> ;
                  <http://example.com/containedTextContainer>
                          [ <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1>
                                    "some Spider." ] ;
                  <https://ontologies.semanticarts.com/gist/hasMagnitude>
                          [ <https://ontologies.semanticarts.com/gist/hasUnitOfMeasure>
                                    <https://ontologies.semanticarts.com/gist/_each> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/identifiedBy>
                          [ a       <http://www.wikidata.org/entity/Q6553274> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    4
                          ] ;
                  <https://ontologies.semanticarts.com/gist/occursIn>
                          [ a       <http://www.wikidata.org/entity/Q86920> ;
                            <https://ontologies.semanticarts.com/gist/name>
                                    "some.txt"
                          ]
                ] .

<http://example.com/commit/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522>
        <https://ontologies.semanticarts.com/gist/hasPart>
                <http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522;hunk=eab30641-eab6-4b44-866d-9dc89fb4bc05> , <http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522;hunk=f2f312bb-49fb-48a1-a62e-323c0519b333> .

<http://example.com/hunk/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522;hunk=eab30641-eab6-4b44-866d-9dc89fb4bc05>
        a       <http://www.wikidata.org/entity/Q113509427> ;
        <https://ontologies.semanticarts.com/gist/affects>
                [ a       <http://www.wikidata.org/entity/Q113515824> ;
                  <http://example.com/containedTextContainer>
                          [ <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1>
                                    "some pig." ] ;
                  <https://ontologies.semanticarts.com/gist/hasMagnitude>
                          [ <https://ontologies.semanticarts.com/gist/hasUnitOfMeasure>
                                    <https://ontologies.semanticarts.com/gist/_each> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/identifiedBy>
                          [ a       <http://www.wikidata.org/entity/Q6553274> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/occursIn>
                          [ a       <http://www.wikidata.org/entity/Q86920> ;
                            <https://ontologies.semanticarts.com/gist/name>
                                    "some.txt"
                          ]
                ] ;
        <https://ontologies.semanticarts.com/gist/produces>
                [ a       <http://www.wikidata.org/entity/Q113515824> ;
                  <http://example.com/containedTextContainer>
                          [ <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1>
                                    "some Pig." ] ;
                  <https://ontologies.semanticarts.com/gist/hasMagnitude>
                          [ <https://ontologies.semanticarts.com/gist/hasUnitOfMeasure>
                                    <https://ontologies.semanticarts.com/gist/_each> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/identifiedBy>
                          [ a       <http://www.wikidata.org/entity/Q6553274> ;
                            <https://ontologies.semanticarts.com/gist/numericValue>
                                    1
                          ] ;
                  <https://ontologies.semanticarts.com/gist/occursIn>
                          [ a       <http://www.wikidata.org/entity/Q86920> ;
                            <https://ontologies.semanticarts.com/gist/name>
                                    "some.txt"
                          ]
                ] .

<http://example.com/commit/origin=https%3A%2F%2Foriginhere.com%2Frepo.git;commit=0e40522>
        a       <http://www.wikidata.org/entity/Q20058545> ;
        <http://purl.org/dc/terms/creator>
                [ <https://ontologies.semanticarts.com/gist/name>
                          "Justin" ;
                  <https://schema.org/email>  "justin2004@hotmail.com"
                ] ;
        <http://purl.org/dc/terms/subject>
                [ <http://purl.org/dc/terms/description>
                          "caps on pig and spider." ;
                  <http://purl.org/dc/terms/title>
                          "capitalization"
                ] ;
        <https://ontologies.semanticarts.com/gist/atDateTime>
                "2022-08-23T07:25:26-04:00"^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
        <https://ontologies.semanticarts.com/gist/isIdentifiedBy>
                [ <https://ontologies.semanticarts.com/gist/uniqueText>
                          "0e40522" ] .
```


## Why

## How

def in terms of more primitive things
  eventually bottom out
wd:Q20058545 commit
https://www.wikidata.org/wiki/Q20058545

wd:Q113509427 hunk
https://www.wikidata.org/wiki/Q113509427
  (part of a unifiedDiff)

wd:Q113515824   contiguous lines of text
https://www.wikidata.org/wiki/Q113515824

wd:Q86920   text file
https://www.wikidata.org/wiki/Q86920

wd:Q6553274   line number
https://www.wikidata.org/wiki/Q6553274

unpacking (em dash)
  exploded diagram
  a good ontology will help you put space between things by having a thoughtful set of generic predicates.
  this unpacked form isn't the form for a particular application -- it is the form for all applications.
  the unified diff form works well for the `patch` program and `git` but not for X.
  i know that means more triples -- RDF* == bodge wire picture



enrichment
  connecting vulnerabilies (CVEs) to file names / commits / tags / releases
  AAA


unix -- radical program composability
  using RDF graphs as input and output
  https://twitter.com/stylewarning/status/1561759622167293954?s=20&t=FyJW8TW0F-SfD2HqEfciXQ
