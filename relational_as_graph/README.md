# Querying a Relational Database with a Graph Query Language


## Introduction

If you'd like to produce a graph (RDF) from a relational database then this post might be useful for you.

In this post we'll use:
- [PostgreSQL](https://www.postgresql.org/)
  - A Relational Database
- [SPARQL Anything](https://github.com/SPARQL-Anything/sparql.anything)
  - A tool built atop the Apache Jena project that presents structured data as RDF


## Examples

I've loaded up an instance of Postgres with a few tables:

```bash
echo "\d" | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin
```

Produces:
```csv
Schema,Name,Type,Owner
public,freightrates,table,postgres
public,orderlist,table,postgres
public,plantports,table,postgres
public,productsperplant,table,postgres
public,vmicustomers,table,postgres
public,whcapacities,table,postgres
public,whcosts,table,postgres
```

Let's peek at one of the tables:

```bash
echo "select * from whcosts limit 3" | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin
```

Produces:
```csv
WH,Cost/unit
PLANT15,1.42
PLANT17,0.43
PLANT18,2.04
```

The tables happen to be about a supply chain but it content doesn't matter for this post.

We've recently added a feature to SPARQL Anything that allows us to more easily transform these tables into RDF.

First let's just enumerate the table names using a SPARQL query:

```sparql
PREFIX  xyz:  <http://sparql.xyz/facade-x/data/>
PREFIX  fx:   <http://sparql.xyz/facade-x/ns/>
SELECT  *
WHERE
  { SERVICE <x-sparql-anything:>
      { fx:properties
                  fx:command      "echo \\\\d | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin" ;
                  fx:media-type   "text/csv" ;
                  fx:csv.headers  "true" .
        []      xyz:Name        ?table_name
      }
  }
```

The Postgres (psql) command to list the tables is `\d`.
Notice we had to think carefully about escaping that backslash. :)
Other than that, the command text is exactly what you'd type in the shell.
We just happen to be embedding that command text into a SPARQL query.

The SPARQL Anything engine, upon seeing a `SERVICE` clause using its protocol `x-sparql-anything:` springs to life and runs our shell command then it interprets the output of that command as csv (with a header row).
We just want the column called "Name" (which SPARQL Anything makes a URI for called `xyz:Name`).

And here are the results:

|table\_name       |
|------------------|
|plantports        |
|vmicustomers      |
|whcosts           |
|orderlist         |
|productsperplant  |
|whcapacities      |
|freightrates      |


Now let's just focus on one table and transform it into some modeled RDF.

```sparql
PREFIX  fx:   <http://sparql.xyz/facade-x/ns/>
PREFIX  ex:   <http://example.com/>
PREFIX  gist: <https://ontologies.semanticarts.com/gist/>
PREFIX  xyz:  <http://sparql.xyz/facade-x/data/>
PREFIX  xsd:  <http://www.w3.org/2001/XMLSchema#>
CONSTRUCT
  {
    ?warehouse_iri ex:somePredicateGoesHere ?something .
    ?warehouse_iri a gist:Building .
    ?something gist:hasMagnitude ?mag .
    ?mag gist:hasUnitOfMeasure gist:_USDollar .
    ?mag gist:numericValue ?cost_double .
  }
WHERE
  { SERVICE <x-sparql-anything:>
      { BIND(concat("echo \"select * from whcosts\" | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin") AS ?cmd)
        fx:properties
                  fx:command       ?cmd ;
                  fx:media-type    "text/csv" ;
                  fx:csv.headers   "true" .
        []        xyz:costperunit  ?cost ;
                  xyz:wh           ?warehouse
        BIND(IRI(concat(str(ex:), "Warehouse_", ?warehouse)) AS ?warehouse_iri)
        BIND(bnode() AS ?mag)
        BIND(bnode() AS ?something)
        BIND(xsd:double(?cost) AS ?cost_double)
      }
  }
```

Which produces this graph:
```ttl
@prefix ex:   <http://example.com/> .
@prefix fx:   <http://sparql.xyz/facade-x/ns/> .
@prefix gist: <https://ontologies.semanticarts.com/gist/> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix xyz:  <http://sparql.xyz/facade-x/data/> .

ex:Warehouse_PLANT06  a           gist:Building ;
        ex:somePredicateGoesHere  [ gist:hasMagnitude  [ gist:hasUnitOfMeasure  gist:_USDollar ;
                                                         gist:numericValue      "0.55"^^xsd:double
                                                       ]
                                  ] .

ex:Warehouse_PLANT19  a           gist:Building ;
        ex:somePredicateGoesHere  [ gist:hasMagnitude  [ gist:hasUnitOfMeasure  gist:_USDollar ;
                                                         gist:numericValue      "0.64"^^xsd:double
                                                       ]
                                  ] .

ex:Warehouse_PLANT13  a           gist:Building ;
        ex:somePredicateGoesHere  [ gist:hasMagnitude  [ gist:hasUnitOfMeasure  gist:_USDollar ;
                                                         gist:numericValue      "0.47"^^xsd:double
                                                       ]
                                  ] .
...
```

Note that I spent only 38 seconds "modeling" the situation where each warehouse has a associated with it a certain cost per unit for sending units through it.
I wouldn't model the situation that way but this post isn't about modeling.
I just want to demonstrate the technical moves here.

Also note that I hardcoded the string "select * from whcosts" but you could `BIND` variables and do something more programmatic.

For example, here is one way to iterate over all the tables and put generate the resulant naive RDF:

```sparql
PREFIX  xyz:  <http://sparql.xyz/facade-x/data/>
PREFIX  fx:   <http://sparql.xyz/facade-x/ns/>
PREFIX  ex:   <http://example.com/>
CONSTRUCT 
  {
    GRAPH ?g
      { ?s ?p ?o .}
  }
WHERE
  { SERVICE <x-sparql-anything:>
      { { { SELECT  *
            WHERE
              { SERVICE <x-sparql-anything:>
                  { fx:properties
                              fx:command      "echo \\\\d | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin" ;
                              fx:media-type   "text/csv" ;
                              fx:csv.headers  "true" .
                    []        xyz:Name        ?table_name
                  }
              }
          }   
          BIND(concat("echo \"select * from ", ?table_name, " limit 30\" | PGPASSWORD=mysecretpassword psql -h 172.17.0.1 -p 5432 -U postgres --csv -f /dev/stdin") AS ?cmd)
          BIND(IRI(concat(str(ex:), "NamedGraph_", ?table_name)) AS ?g)
        }
        fx:properties
                  fx:command      ?cmd ;
                  fx:media-type   "text/csv" ;
                  fx:csv.headers  "true" .
        ?s        ?p              ?o
      }
  }
```

Notice this SPARQL query doesn't hardcode table names so it can accomodate any changes to the database of tables.

It produces this RDF (I've remove some triples for brevity):
```trig
@prefix ex:  <http://example.com/> .
@prefix fx:  <http://sparql.xyz/facade-x/ns/> .
@prefix xyz: <http://sparql.xyz/facade-x/data/> .

ex:NamedGraph_vmicustomers {
    [ a       fx:root ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_6>
              [ xyz:customers   "V55555555_9" ;
                xyz:plant_code  "PLANT02"
              ] ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_7>
              [ xyz:customers   "V55555_10" ;
                xyz:plant_code  "PLANT02"
              ] ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_9>
              [ xyz:customers   "V555555555555555_18" ;
                xyz:plant_code  "PLANT06"
              ]
    ] .
}

ex:NamedGraph_freightrates {
    [ a       fx:root ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_14>
              [ xyz:carrier       "V444_6" ;
                xyz:carrier_type  "V88888888_0" ;
                xyz:dest_port_cd  "PORT09" ;
                xyz:max_wgh_qty   "4.99" ;
                xyz:minimum_cost  " $43.23 " ;
                xyz:minm_wgh_qty  "0" ;
                xyz:mode_dsc      "AIR   " ;
                xyz:orig_port_cd  "PORT08" ;
                xyz:rate          " $1.83 " ;
                xyz:svc_cd        "DTD" ;
                xyz:tpt_day_cnt   "2"
              ] ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_15>
              [ xyz:carrier       "V444_6" ;
                xyz:carrier_type  "V88888888_0" ;
                xyz:dest_port_cd  "PORT09" ;
                xyz:max_wgh_qty   "9.99" ;
                xyz:minimum_cost  " $43.23 " ;
                xyz:minm_wgh_qty  "5" ;
                xyz:mode_dsc      "AIR   " ;
                xyz:orig_port_cd  "PORT08" ;
                xyz:rate          " $1.83 " ;
                xyz:svc_cd        "DTD" ;
                xyz:tpt_day_cnt   "2"
              ] ;
      <http://www.w3.org/1999/02/22-rdf-syntax-ns#_16>
              [ xyz:carrier       "V444_6" ;
                xyz:carrier_type  "V88888888_0" ;
                xyz:dest_port_cd  "PORT09" ;
                xyz:max_wgh_qty   "99999.99" ;
                xyz:minimum_cost  " $43.23 " ;
                xyz:minm_wgh_qty  "2000" ;
                xyz:mode_dsc      "AIR   " ;
                xyz:orig_port_cd  "PORT08" ;
                xyz:rate          " $0.64 " ;
                xyz:svc_cd        "DTD" ;
                xyz:tpt_day_cnt   "2"
              ]
    ] .
}
```

Notice this time we are producing quads (triples in a named graph).
We get one named graph per databse table.

## Final Thoughts

This kind of "support" for relational database sources is stringy and not first class.
SPARQL Anything recognizes csv as a first class data input and we are just bridging the gap between the databse and csv by using the `fx:command` property.

But I do like that for small to medium sized relational source systems we could quickly start modeling and transforming into RDF without much tooling.

Tables are simply projections of graphs so the more tables we express as graphs the better.

Have fun constructing graphs!
