# json-ld

I had time understanding json-ld until I used turtle files a lot. 
Now as I look at json-ld it makes sense. 
When using triples (subject predicate object) the main thing to remember is that you must fully qualify. 
That is what all this `@context` and `@id` is about in json-ld.


### example

This example below comes from https://json-ld.org/playground/

Here is a turtle file (containing triples).

```
_:b0 <http://schema.org/jobTitle> "Professor" .
_:b0 <http://schema.org/name> "Jane Doe" .
_:b0 <http://schema.org/telephone> "(425) 123-4567" .
_:b0 <http://schema.org/url> <http://www.janedoe.com> .
_:b0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://schema.org/Person> .
```

The file talks about something with a jobTitle, name, etc. 
The `_:b0` just means that we don't know the URI for the subject but, nevertheless, we are going to say some things about some subject.



We could make this file easier for a person to edit with prefixes:

```
@prefix sc: <http://schema.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

_:b0 sc:jobTitle "Professor" .
_:b0 sc:name "Jane Doe" .
_:b0 sc:telephone "(425) 123-4567" .
_:b0 sc:url <http://www.janedoe.com> .
_:b0 rdf:type sc:Person .
```

But note that everything is still fully qualified. We just have a shortcut notation now.

Now json-ld:

```
{
  "@context": "http://schema.org/",
  "@type": "Person",
  "name": "Jane Doe",
  "jobTitle": "Professor",
  "telephone": "(425) 123-4567",
  "url": "http://www.janedoe.com"
}
```


See how the value of `@context` is just the prefix for all the raw keys: name, jobTitle, telephone, and url.
Just like in the turtle file with prefixes defined.

And `rdf:type` gets some special treatment in json-ld as `@type`.
Often in turtle files you'll see `rdf:type` abbreviated as `a`.

This example does not use `@id` but that just means "this is a URI" as opposed to some other data type (like string or integer).



### efficiency

If you use terms from many vocabularies/ontologies then you might not want to keep transmitting a long list of `@context` values.
In that case it [looks](https://niem.github.io/json/reference/json-ld/context/) like you can refer to some resource that contains your context.

`A key "@context" may have, as a value, a URI, which is a name for a JSON-LD context object.`

```
{
  "@context" : "https://example.org/my/context.json",
  "nc:PersonPreferredName": "Morty"
}
```

