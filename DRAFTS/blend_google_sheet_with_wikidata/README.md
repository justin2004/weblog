# Blending a Google Sheet with Wikidata


There is [interest](https://phabricator.wikimedia.org/T181319) in the Wikidata community in accessing external tabular data in a [SPARQL](https://en.wikipedia.org/wiki/SPARQL) query. While that development looks like it is ongoing you can already access tabular data in a SPARQL query with [SPARQL Anything](https://github.com/SPARQL-Anything/sparql.anything).


Here is the Google Sheet we'll use in this example:


|item\_name   |item\_Q   |item\_note                      |
|-------------|----------|--------------------------------|
|hair brush   |Q1642980  |can be used to remover tangles  |
|tooth brush  |          |soft bristles are the best      |
|tweezers     |Q192504   |some wee hands                  |
|diode        |Q11656    |                                |


Which lives here:

`https://docs.google.com/spreadsheets/d/1ZE5SGutY1-_O4OFj-W9YPcXObhAfUaCX73SKpSlTRLk/`


First you have to run SPARQL Anything. There are instruction in the project's README and [here](https://github.com/SPARQL-Anything/sparql.anything/blob/v0.3-DEV/BROWSER.md) for a docker deployment (which is how I run it for this example).


The query (wrapped in a curl call so you can run it in a bash shell) is below.
It uses the Wikidata Q number in the sheet to enrich the rows in the sheet with information about the type of thing each item is and the use of each item.

The query:

```
curl --silent 'http://localhost:3000/sparql.anything'  \
--header "Accept: text/csv" \
--data-urlencode 'query=
PREFIX xyz: <http://sparql.xyz/facade-x/data/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX fx: <http://sparql.xyz/facade-x/ns/>
PREFIX wd:       <http://www.wikidata.org/entity/>         # Wikibase entity - item or property. 
PREFIX wdt:      <http://www.wikidata.org/prop/direct/>    # Truthy assertions about the data, links entity to value directly. 
PREFIX wikibase: <http://wikiba.se/ontology#>
PREFIX bd: <http://www.bigdata.com/rdf#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT ?item_name ?item_q ?item_note ?item_use_label ?item_superclass ?item_superclass_label
WHERE {
   SERVICE <x-sparql-anything:media-type=text/csv,csv.headers=true,location=https://docs.google.com/spreadsheets/d/1ZE5SGutY1-_O4OFj-W9YPcXObhAfUaCX73SKpSlTRLk/export?exportFormat=csv> {
fx:properties fx:csv.null-string "" .
   ?item xyz:item_name ?item_name .
   optional{?item xyz:item_Q         ?item_q } .
   optional{?item xyz:item_note      ?item_note } .
   bind(if(bound(?item_q),iri(concat(str(wd:),?item_q)),"this will not match anything in the subject position") as ?item_q_uri) .
}
optional {
    service <https://query.wikidata.org/sparql>{
    ?item_q_uri wdt:P279 ?item_superclass .  
    optional {
        ?item_superclass rdfs:label ?item_superclass_label .
        filter(lang(?item_superclass_label) = "en")
    }
    optional {
        ?item_q_uri wdt:P366 ?item_use .  
        ?item_use rdfs:label ?item_use_label .
        filter(lang(?item_use_label) = "en")
    }
}
}
}'
```


The output:




|item\_name   |item\_q   |item\_note          |item\_use\_label    |item\_superclass    |item\_superclass\_label|
|-------------|----------|--------------------|--------------------|--------------------|-----------------------|
|diode        |Q11656    |                    |electrical resistance|http://www\.wikidata\.org/entity/Q11653|electronic component   |
|hair brush   |Q1642980  |can be used to remover tangles|hair care           |http://www\.wikidata\.org/entity/Q10528974|personal hygiene item  |
|hair brush   |Q1642980  |can be used to remover tangles|hairdressing        |http://www\.wikidata\.org/entity/Q10528974|personal hygiene item  |
|hair brush   |Q1642980  |can be used to remover tangles|hair care           |http://www\.wikidata\.org/entity/Q5639584|hairstyling tool       |
|hair brush   |Q1642980  |can be used to remover tangles|hairdressing        |http://www\.wikidata\.org/entity/Q5639584|hairstyling tool       |
|hair brush   |Q1642980  |can be used to remover tangles|hair care           |http://www\.wikidata\.org/entity/Q614467|brush                  |
|hair brush   |Q1642980  |can be used to remover tangles|hairdressing        |http://www\.wikidata\.org/entity/Q614467|brush                  |
|tweezers     |Q192504   |some wee hands      |motion              |http://www\.wikidata\.org/entity/Q1378235|forceps                |
|tweezers     |Q192504   |some wee hands      |motion              |http://www\.wikidata\.org/entity/Q1074814|surgical instrument    |
|tweezers     |Q192504   |some wee hands      |motion              |http://www\.wikidata\.org/entity/Q834028|laboratory equipment   |
|tweezers     |Q192504   |some wee hands      |motion              |http://www\.wikidata\.org/entity/Q2578402|hand tool              |
|tooth brush  |          |soft bristles are the best|                    |                    |                       |



SPARQL Anything supports more than just blending of tabular data (see its README).
While you could certainly do something like this example with your favorite programming language I think it is quite convenient to have the ability to access non-graph sources of data in a SPARQL query.
