# thinking about representing software usage as a sequence of processes in RDF


My family took a car trip recently and we wanted our son to be able to watch some episodes of a show he likes along the way.
We have an iPad 2 and I found some Daniel Tiger episodes on YouTube. 
I just needed to find some software to traverse the "path" between the YouTube video and the playback of video on the iPad.

This time I did that traversal manually but wouldn't it have been neat if I could have done something like:

```
prefix obi: <http://purl.obolibrary.org/obo/obi.owl#>
prefix iao: <http://purl.obolibrary.org/obo/iao.owl#>
prefix ro:  <http://purl.obolibrary.org/obo/ro.owl#>
prefix pretend: <http://blah.com/things/>

select ?consumer where {
  ?input    (iao:is_specified_input_of/iao:has_specified_output_of)+ ?output .
  ?output    iao:is_specified_input_of ?consumer .
  ?consumer  a obi:display_function .
  ?consumer ro:located_in pretend:iPad2 .
  filter(?input = <https://www.youtube.com/watch?v=923WfmDgQMc> ) .
}
```


`(iao:is_specified_input_of/iao:has_specified_output_of)+`

is shorthand for something like a chain a processes:

```
?input0   iao:is_specified_input_of   ?process0 .
?process0 iao:has_specified_output_of ?output0 .

?output0   iao:is_specified_input_of   ?process1 .
?process1  iao:has_specified_output_of ?output1 .
```

etc.



I started to make an ontology that could represent the steps involved.
- using software to:
    - download files from the web
    - convert between video container files and transcode
    - transfer files between locally networked devices
    - play audio/video files on an iPad2

but it seems like there are some existing ontologies that will work.
Those include:

- Ontology for Biomedical Investigations 
- Information Artifact Ontology 
- Relation Ontology 
- Software Ontology 

All of which can be found at http://www.obofoundry.org/




### possibility
If we were to encode all program (software) capabilities into RDF then SPARQL queries could tell you if something you want to do with software is possible.


### program selection
If you modified the query to output all the processes along the way then you could see the sequence of programs you would need to carry out your desired task. I don't think SPARQL has paths as a first class thing yet but Stardog has an extension for that.

Perhaps my SPARQL query would have returned something like:

`youtube-dl, ffmpeg, python -m http.server, FileBrowser (Apple App Store)`


### program configuration
If each transformation function that software could perform (swo:is_executed_in) came with annotations that contain the arguments given to the command line interface of the program to make it perform the desired function then you'd have some great hints about what to type (at a command shell).


### program generation
And if the Software Ontology had Classes for command line arguments we would be getting closer to SPARQL queries that could output shell scripts.

---


Note that I've taken some shortcuts for readability.

e.g.  ro:located_in is really <http://purl.obolibrary.org/obo/RO_0001025>





