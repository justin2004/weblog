# SPARQL Value Fuctions 

When I read Bob DuCharme's [blog on using custom javascript functions](https://www.bobdc.com/blog/arqjavascript/) in SPARQL queries I knew I needed to try it out.
What I really wanted was to be able to call functions from some [npm](https://www.npmjs.com/) libraries.
Turns out I wasn't able to figure out how to do that.
It might not be a simple thing to do because Apache Jena doesn't bundle a node runtime... also I didn't even look at how Apache Jena (ARQ specifically) is evaluating this custom javascript. Still, the ability to call vanilla javascript in a SPARQL query is nice.

But I still wanted to call someone else's library functions so I moved onto another option: SPARQL Value Functions.
At least that is what Apache Jena [calls this custom fuction pluggability](https://jena.apache.org/documentation/query/writing_functions.html).

Here is what I wanted to do...

Take some non-RDF data with string date representations that were messy and canonicalize them (to xsd:dateTime since SPARQL respects that format).

Here is the csv example we'll work with:

|classification\_one |classification\_two |classification\_three|company\_system\_of\_record|company\_id |company\_name       |company\_inception       |
|--------------------|--------------------|--------------------|--------------------|------------|--------------------|-------------------------|
|Energy, chemicals and utilities|                    |                    |CompanyX\_DeptY\_SystemA|1           |ABT Inc\.           |Last day of August 2004  |
|Energy, chemicals and utilities|Chemicals           |                    |CompanyX\_DeptY\_SystemM|2           |                    |                         |
|Energy, chemicals and utilities|Electricity \- nuclear|                    |CompanyX\_DeptY\_SystemZ|3           |                    |OCT 1989                 |
|Energy, chemicals and utilities|Electricity \- renewables|                    |CompanyX\_DeptY\_SystemZ|4           |                    |DEC 2011                 |
|Energy, chemicals and utilities|Electricity \- renewables|Biomass             |CompanyX\_DeptY\_SystemM|5           |Fred's Renewables LLC|                         |
|Energy, chemicals and utilities|Electricity \- renewables|Hydro               |CompanyX\_DeptY\_SystemP|6           |WAT Inc\.           |9 January 2000           |
|Energy, chemicals and utilities|thermal             |                    |CompanyX\_DeptY\_SystemQ|7           |                    |5 Mar 1992               |
|Energy, chemicals and utilities|thermal             |coal                |CompanyX\_DeptY\_SystemQ|8           |                    |19 Jun 2020              |
|Financial institutions|                    |                    |CompanyX\_DeptY\_SystemM|9           |Pet E\. Cash Co\.   |                         |
|Financial institutions|Asset / investment management and funds|                    |CompanyX\_DeptY\_SystemM|10          |                    |                         |


(I started with a .csv I got [here](https://github.com/kg-construct/rml-questions/discussions/3) and added some columns to it.)

You'll notice there is some taxonomy information in there as well as some company information.
Also notice how each source system uses different date representations.
I didn't want to just do a regex for each style.
I was looking for an 80/20 rule approach and a general way to add functionality to SPARQL queries.


Here are the triples my construct query produced:
```
@prefix datething: <java:datething.> .
@prefix ex:        <http://www.example.com/> .
@prefix fx:        <http://sparql.xyz/facade-x/ns/> .
@prefix ns:        <http://sparql.xyz/facade-x/ns/> .
@prefix rdf:       <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix skos:      <http://www.w3.org/2004/02/skos/core#> .
@prefix xsd:       <http://www.w3.org/2001/XMLSchema#> .
@prefix xyz:       <http://sparql.xyz/facade-x/data/> .

[ rdf:type           ex:Company ;
  ex:categorizedBy   ex:thermal , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "1992-03-05T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "7" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemQ>
                     ]
] .

ex:thermal  rdf:type  skos:Concept ;
        skos:broader  <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> .

ex:Hydro  rdf:type    skos:Concept ;
        skos:broader  <http://www.example.com/Electricity%20-%20renewables> .

<http://www.example.com/Electricity%20-%20renewables>
        rdf:type      skos:Concept ;
        skos:broader  <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> .

[ rdf:type          ex:Company ;
  ex:categorizedBy  <http://www.example.com/Financial%20institutions> ;
  ex:hasID          [ rdf:type         ex:Identifier ;
                      ex:identifiedBy  "9" ;
                      ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemM>
                    ] ;
  ex:name           "Pet E. Cash Co."
] .

<http://www.example.com/Electricity%20-%20nuclear>
        rdf:type      skos:Concept ;
        skos:broader  <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> .

ex:Chemicals  rdf:type  skos:Concept ;
        skos:broader  <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> .

[ rdf:type          ex:Company ;
  ex:categorizedBy  <http://www.example.com/Asset%20%2F%20investment%20management%20and%20funds> , <http://www.example.com/Financial%20institutions> ;
  ex:hasID          [ rdf:type         ex:Identifier ;
                      ex:identifiedBy  "10" ;
                      ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemM>
                    ]
] .

<http://www.example.com/Asset%20%2F%20investment%20management%20and%20funds>
        rdf:type      skos:Concept ;
        skos:broader  <http://www.example.com/Financial%20institutions> .

<http://www.example.com/Energy%2C%20chemicals%20and%20utilities>
        rdf:type  skos:Concept .

ex:Biomass  rdf:type  skos:Concept ;
        skos:broader  <http://www.example.com/Electricity%20-%20renewables> .

[ rdf:type           ex:Company ;
  ex:categorizedBy   ex:Hydro , <http://www.example.com/Electricity%20-%20renewables> , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "2000-01-09T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "6" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemP>
                     ] ;
  ex:name            "WAT Inc."
] .

[ rdf:type           ex:Company ;
  ex:categorizedBy   <http://www.example.com/Electricity%20-%20nuclear> , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "1989-10-01T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "3" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemZ>
                     ]
] .

[ rdf:type           ex:Company ;
  ex:categorizedBy   <http://www.example.com/Electricity%20-%20renewables> , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "2011-12-01T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "4" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemZ>
                     ]
] .

ex:coal  rdf:type     skos:Concept ;
        skos:broader  ex:thermal .

[ rdf:type           ex:Company ;
  ex:categorizedBy   ex:coal , ex:thermal , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "2020-06-19T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "8" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemQ>
                     ]
] .

[ rdf:type          ex:Company ;
  ex:categorizedBy  ex:Chemicals , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasID          [ rdf:type         ex:Identifier ;
                      ex:identifiedBy  "2" ;
                      ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemM>
                    ]
] .

[ rdf:type           ex:Company ;
  ex:categorizedBy   <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasActualStart  "2004-08-31T00:00:00.000Z"^^xsd:dateTime ;
  ex:hasID           [ rdf:type         ex:Identifier ;
                       ex:identifiedBy  "1" ;
                       ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemA>
                     ] ;
  ex:name            "ABT Inc."
] .

[ rdf:type          ex:Company ;
  ex:categorizedBy  ex:Biomass , <http://www.example.com/Electricity%20-%20renewables> , <http://www.example.com/Energy%2C%20chemicals%20and%20utilities> ;
  ex:hasID          [ rdf:type         ex:Identifier ;
                      ex:identifiedBy  "5" ;
                      ex:inSystem      <http://www.example.com/system/CompanyX_DeptY_SystemM>
                    ] ;
  ex:name           "Fred's Renewables LLC"
] .

<http://www.example.com/Financial%20institutions>
        rdf:type  skos:Concept .

```
(NOTE: I wouldn't recommend using blank nodes for the companies like I did here but I am not showing off domain modeling in RDF in this post.)

Here is the query that produced those triples (in a bash command for ease of replication):
```
curl --silent 'http://localhost:3000/sparql.anything'  \
--data-urlencode 'query=
PREFIX xyz: <http://sparql.xyz/facade-x/data/>
PREFIX ns: <http://sparql.xyz/facade-x/ns/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX fx: <http://sparql.xyz/facade-x/ns/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>
prefix ex: <http://www.example.com/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX datething: <java:datething.>
construct {?concept_one a skos:Concept .
           ?concept_two a skos:Concept .
           ?concept_three a skos:Concept .
           ?concept_three skos:broader ?concept_two .
           ?concept_two skos:broader ?concept_one .
           ?company a ex:Company .
           ?company ex:hasActualStart ?when .
           ?company ex:name ?company_name .
           ?company ex:hasID ?company_identifier .
           ?company ex:categorizedBy ?concept_one .
           ?company ex:categorizedBy ?concept_two .
           ?company ex:categorizedBy ?concept_three .
           ?company_identifier a ex:Identifier .
           ?company_identifier ex:identifiedBy ?company_id .
           ?company_identifier ex:inSystem ?source_system .
}
WHERE {
  service <x-sparql-anything:csv.headers=true,location=/app/aa.csv> {
    fx:properties fx:csv.null-string "" .
    ?root a ns:root ;
          ?slotp ?row .
    optional {?row xyz:classification_one ?one_string 
              bind(uri(concat(str(ex:),encode_for_uri(?one_string))) as ?concept_one)}
    optional {?row xyz:classification_two ?two_string 
              bind(uri(concat(str(ex:),encode_for_uri(?two_string))) as ?concept_two)}
    optional {?row xyz:classification_three ?three_string 
              bind(uri(concat(str(ex:),encode_for_uri(?three_string))) as ?concept_three)}
    {
        ?row xyz:company_id ?company_id .
        ?row xyz:company_system_of_record ?source_system_string .
        bind(uri(concat(str(ex:),"system/",encode_for_uri(?source_system_string))) as ?source_system)
        optional{ ?row xyz:company_name ?company_name }
            bind(bnode() as ?company)
            bind(bnode() as ?company_identifier)
    }
    optional { ?row xyz:company_inception ?when_string 
               bind(strdt(datething:parse(?when_string),xsd:dateTime) as ?when)
    }
  }
}'

```



These 2 lines do the custom function invocation.

```
PREFIX datething: <java:datething.>
bind(strdt(datething:parse(?when_string),xsd:dateTime) as ?when)
```

The function `datething:parse` takes a variable (bound to a string) as an argument and returns an xsd:dateTime string representation then we cast it to an `xsd:dateTime` with `strdt`.
In order to allow that to happen you have to put a .jar on Apache Jena Fuseki's classpath.
I am running SPARQL Anything (which is Fuseki but with some added functionality to allow it to treat non-RDF data as RDF).

Here are the steps to invoke this messy string date parsing function:

1) Build the .jar file for the `datething:parse` functionality by following the instructions [here](https://github.com/justin2004/datething) under the "how" section.


2) `git clone` [SPARQL Anything](https://github.com/SPARQL-Anything/sparql.anything).

3) Copy the .jar you produced in (1) to directory you created in (2). 

4) Run SPARQL Anything in a docker container (listening on port 3000) by following [these](https://github.com/SPARQL-Anything/sparql.anything/blob/v0.5-DEV/BROWSER.md) instructions. (At this point Fuseki's classpath should have that .jar file on it.)

5) Download `aa.csv` (the .csv example) from this git repo and copy it into the SPARQL Anything directory.

6) Run the bash command above (with the SPARQL query) and you should have your constructed triples!


So with this `datething:parse` functionality you can triplify, say, a spreadsheet that has a variety of date representations in it and likely get most of the dates canonicalized so you can sort, filter, etc. on them in a SPARQL query.
([Here](https://github.com/justin2004/weblog/tree/master/blend_google_sheet_with_wikidata) is my post on using SPARQL Anything to extract triples from a public google sheet.)

Happy triplifying!
