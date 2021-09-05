# Dynamic Pagination with SPARQL Anything

[SPARQL Anything]() can talk to REST APIs. 
Some REST APIs employ pagination to reduce the number of results shown and deliver results incrementally to the client.
An example of such an API is the [arxiv API](https://arxiv.org/help/api/user-manual#Quickstart).

For example, this curl command does a search for papers written by Seth Lloyd where the abstract contains the word "coherent":
``curl 'http://export.arxiv.org/api/query?search_query=abs:coherent+AND+au:seth%20lloyd&max_results=10&start=0'``

It returns XML and part of that XML looks like:
```
  <opensearch:totalResults xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">153</opensearch:totalResults>
  <opensearch:startIndex xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">1</opensearch:startIndex>
  <opensearch:itemsPerPage xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">10</opensearch:itemsPerPage>
```

So there are 16 "pages" of results with 10 items per page.
Some REST APIs use page numbers but this one uses offsets (or start index).

Page number 0 has offset 0, page number 1 has offset 10, etc.
Finally, page number 15 has offset 150.


You can handle pagination and step through pages in any application code but you can also step through those pages in a single SPARQL query.

First you have to run SPARQL Anything.
There are instructions on the project's README and in for example I am using the docker image described [here]().


Here is the query (which you can run in a bash shell):


```sparql
curl --silent 'http://localhost:3000/sparql.anything'  \
--header "Accept: application/turtle" \
--data-urlencode 'query=
PREFIX xyz: <http://sparql.xyz/facade-x/data/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX fx: <http://sparql.xyz/facade-x/ns/>
prefix xhtml: <http://www.w3.org/1999/xhtml#>
prefix what: <https://html.spec.whatwg.org/#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
prefix a9: <http://a9.com/-/spec/opensearch/1.1/>
construct {?s ?p ?o}
WHERE {
bind(encode_for_uri("coherent") as ?string_in_abstract)
bind(encode_for_uri("seth lloyd") as ?author)
bind(encode_for_uri("10") as ?results_per_page)
bind(concat("x-sparql-anything:media-type=application/xml,location=http://export.arxiv.org/api/query?search_query=abs:",
                ?string_in_abstract,"+AND+au:",?author,"&max_results=",?results_per_page) as ?service_string) .
bind(iri(concat(?service_string,"&start=0")) as ?service)
service ?service { # this first service just gets the number of results and discards the first page of actual results
values ?allowed_page { 0 1 2 3 } .  # pages are 0-based and these are the pages you want (if they exist)
[] a fx:root ;
   ?slot_p  [ a a9:totalResults ;
              rdf:_1 ?total_results ] ;
   ?slot_p1 [ a a9:itemsPerPage ;
              rdf:_1 ?items_per_page ] ;
   ?slot_p2 [ a a9:startIndex ;
              rdf:_1 ?start_index ] .
bind(xsd:integer(ceil(xsd:integer(?total_results) / xsd:integer(?items_per_page))) as ?total_pages) .
filter(xsd:integer(?allowed_page) < ?total_pages) .
bind(str(xsd:integer(?allowed_page) * xsd:integer(?items_per_page)) as ?offset) .
}
bind(iri(concat(?service_string,"&start=",coalesce(?offset),"")) as ?service_step) .
service ?service_step { # this service steps through each allowed page of results.
                        # the search results of the previous service are discarded to allow all binding to happen in a single
                        # service (this one) for simplicity.
?s ?p ?o .
}
}'
```


Which will produce triples something like:
```
[ a        fx:root , <http://www.w3.org/2005/Atom#feed> ;
  rdf:_1   [ a         <http://www.w3.org/2005/Atom#link> 
 ...
]

[ a        fx:root , <http://www.w3.org/2005/Atom#feed> ;
  rdf:_1   [ a         <http://www.w3.org/2005/Atom#link> 
 ...
]

[ a        fx:root , <http://www.w3.org/2005/Atom#feed> ;
  rdf:_1   [ a         <http://www.w3.org/2005/Atom#link> 
 ...
]

[ a        fx:root , <http://www.w3.org/2005/Atom#feed> ;
  rdf:_1   [ a         <http://www.w3.org/2005/Atom#link> 
 ...
]

```

You'll see 4 subjects at the top level.
One for each page we allowed (0, 1, 2, and 3).
Each subject represents a page of results that you can extract values of interest out of and even transform them into thoughtfully modeled triples.
