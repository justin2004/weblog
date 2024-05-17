# iDE - Integrat_ing_ Development Enrivonment


## An iDE?

You've heard of IDEs (Integrated development environment).
You probably use one or know someone who does.

I'd like to contrast IDEs (integrat_ed_) with iDEs (integrat_ing_).

"Integrated" connotes finality.
As in "it has already been integrated for you -- you just use it now."

Of course IDEs are extensible but I only know one person that has made an extension/plug-in for an IDE.
On the other hand, I know many vim and emacs users that have made extensions for their iDE.
No, they don't call their thing an iDE but they use it like an iDE.

The spirit of an iDE is ... 
Using [escape hatches](https://wiki.c2.com/?EscapeHatch) to weave together tools that do their thing well.
which is why you might not hear about it ... maybe it doesn't deserve a name...

It might just be that the people that select IDEs do so because it is already integrated (and they just want to work within it) while vim and emacs users are inclined to shave the yak.

The first IDE I used was Eclipse.
I didn't choose it though.
That was the IDE my team was using to develop and maintain some software and all the setup guides were Eclipse oriented.
So I used it as I wasn't prepared to roll my own approach yet.

Long story short, I never enjoyed using it.
I did what I had to in it and used the command line (custom scripts, pipelines, etc.) for everything else.

Fast forward to today -- I get to develop and maintain knowledge graphs and that requires that I modify RDF files.
I want to show you my iDE for the semantic web stack (SPARQL/RDF).


## My RDF workflow

I think an iDE is mostly a patchwork of tools that work easily together.
I've found for tools to work easily together is helps if they can communicate using text.
That can be in the form of files on the filesystem, textual command line options, or textual keyboard input.

Also, the foundational tools ...


<!-- NOTE: you can't always take a monolith IDE with you. -->

<!-- There are some IDE-ish things for the semantic web stack. -->
<!-- I had a colleague that used [TopBraid Composer](https://topbraidcomposer.org/html/) (the predecessor to TopBraid EDG). -->

In order to demonstrate this workflow I set up some RDF files in the `example/` directory.


## Demonstration

First the demonstration then I'll describe the setup.
I thought it would be easier show the workflow with a video.

Here is the video.


TODO insert gif of the async sparql exe

Here are the elements of my semantic web iDE:

- Named terminal sessions
  - [terminal multiplexer (tmux)]()
  - I typically have a session for editing RDF files, editing and running SPARQL queries, and I usually keep a session for each serivice I am running (Apache Jena Fuseki, SPARQL Anything, Protege, etc.)

- Editing, viewing, syntax highlighting/checking, execution
  - [vim]()
    - Note that I get asyncronous SPARQL query execution in vim so I can keep editing queries while running a big query
  - [Apache Jena's riot command]()

- RDF (e.g. turtle file) formatting
  - [rdf-toolkit]()
  - This has the benefit that everyone on your team can use their favorite RDF editor and you can still have minimal diffs (when using version control)

- SPARQL query formatting and execution
  - [Apache Jena]()
    - Note: I've done the same thing with other triple stores (RDFox, GraphDB, Stardog, etc.)

- RDF navigation (jumping to RDF resources)
  - [ctags]()
    - It's been around a long time and is supported by many tools.

- Analyzing/manipulating query results
  - [VisiData]()
    - I highly recommend learning VisiData -- I used [this tutorial](https://jsvine.github.io/intro-to-visidata/index.html).


## Areas of future improvement?


When I need to transform data into RDF I use SPARQL Anything.

When I want to see a tree view of a class hierarchy or taxonomy I often use Protege but for skos based taxonomies I first have to transform to it to a `rdfs:subClassOf` style hierarchy.
I [started on a visidata based tree viewer](https://github.com/saulpw/visidata/discussions/2282#discussioncomment-8633738) but I need to finish it.

When I need to produce a pictorial graph I often use my former colleague's [Turtle Editor Viewer](https://www.semantechs.co.uk/turtle-editor-viewer/).
It might be nice to incorporate that or something like it into my workflow.

I use [LSP](https://langserver.org/) for some langauges.
It would be interesting to think about adding LSP support for RDF and SPARQL files.

Also, the plugin I use for RDF file syntax highlight has support for completion (using [prefix.cc](https://prefix.cc/)) but it didn't work out of the box so I need to tinker with it.
In the meantime I just use vim's built-in tab completion.



## Setup


At the center of it all: [the command line](https://web.stanford.edu/class/cs81n/command.txt), of course.
I assume you are using `bash` as the interpreter but I think the commands will still work if `zsh` was selected for you.

Also, although I use vim I have a colleague who uses emacs in a similar manner.
I bet you could get a similar iDE with several other text editors provided they have sufficient escape hatch capability.

First we need to install some packages (I am assuming a Debian based distro):

```bash
sudo apt install tmux git vim-common default-jre universal-ctags python3
```

Also, I recommend that you [install Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository).
This is how I package [the SPARQL query pretty printer](https://github.com/justin2004/sparql_pretty) and it is useful for running things like instances of Apache Jena Fuseki, SPARQL ANything, etc.
Without Docker, you have to think "do I have the runtime it requires? all the dependencies? the config files? what is this thing's path?"



Set up the vim plugin manager: [Vundle](https://github.com/VundleVim/Vundle.vim)
There are instructions there in its readme.

And put this into your ~/.vimrc in the section designated for Vundle:

```
" for syntax highlighting
Plugin 'niklasl/vim-rdf'
" for running commands asynchronously in vim
Plugin 'https://github.com/skywind3000/asyncrun.vim'
" for quikly commenting on/off blocks of code (in this case in RDF and SPARQL)
Plugin 'tpope/vim-commentary'
```

In vim, run `:PluginInstall` as Vundle requires for new packages.


Download an rdf-toolkit release jarfile.

The current version is [here](https://github.com/edmcouncil/rdf-toolkit/releases/tag/v2.0).

In order to make navigation around RDF files possible we need to format (serialize) turtle files in a standard way.
rdf-toolkit works well as a serializer.

Here is how I sometimes run it over all the turtle files in my current directory:

```bash
ls -1 *ttl | while read IN ; do java -jar ~/Downloads/rdf-toolkit.jar -sdt explicit -dtd -ibn -s $IN > ${IN}_formatted.ttl  ; done
```

Later I'll show you a way to do directly from vim if you prefer.


Navigation

Since we are serializing using rdf-toolkit we can the widely supported `ctags` to jump to URIs (in the same and different files).

`cd` to the `example/` directory in this repository and run the following to build the index file:

```bash
ctags --langdef=turtle --langmap=turtle:.ttl --regex-turtle='/^([<][^>]+[>])/\1/T,urinoprefix/' --regex-turtle='/^([a-z]+:[0-9a-zA-Z_.]+).*/\1/T,uri,a uri/' -V -R .
```

Then you should see a `tags` file in your current directory.
As long as you start vim from that directory the tags index will be used.

Also, you need to tell vim about the lexical syntax of keywords in turtle files.
e.g. URI Qnames have the `:` character, full URIs are surrounded by `<` and `>`, etc.

While we are at the let's set up a few other useful settings for RDF and SPARQL files.
Put this into your .vimrc:

```
" set the filetype to 'sparql' for .sparql and .rq
au BufRead,BufNewFile *.{sparql,rq}   setfiletype sparql
au BufRead,BufNewFile *.{turtle,ttl}  setfiletype turtle

" set up comment characters
au FileType turtle set commentstring=#%s
au FileType sparql set commentstring=#%s

" allow URIs (full and qnames) be to keywords in vim
au FileType turtle set iskeyword=@,48-57,_,192-255,:,-,<,>,/,.

" allow RDF file formatting/syntax checking in vim
au BufRead *.ttl let &l:equalprg='~/Downloads/apache-jena-5.0.0/bin/riot --formatted=turtle --syntax=turtle -'


" define a macro for running the SPARQL query pretty printer
au FileType sparql let @p = '?query=j0v/''/-1/!docker run --rm -i justin2004/sparql_pretty:noh'

" define a macro for executing a SPARQL query and putting the results into visidata
au FileType sparql let @q = 'mm1Gvap"cy''mvap"Cy:split +put\ c buf0:set buftype=nofile:file! `mktemp`:w! /tmp/lala1.sh:q''mzz:AsyncRun tmux split-window bash -l -c "source /tmp/lala1.sh > /tmp/lala1.csv ; vd /tmp/lala1.csv"'
```

Now start vim and edit one of the .ttl files in `examples/`.
Put your cursor on a URI and press `ctrl` `]` to jump to the definition.

You can get more help on jumping to keywords in vim by running:

```
:help ^]
```

or

```
:help tags
```

After you jump to several keywords (URIs) you can jump back through the URIs you came through with `ctrl` `t`.



tmux

Maybe first find a quick tutorial on tmux.
I started with GNU Screen long ago and then upgraded to tmux so I don't have one to recommend but there are several out there.

Create a tmux session called "ontology".
In that session, using vim, open one of the .ttl files in the `examples/` directory.

Now create a tmux session called "query"

Using vim, create a file for your SPARQL queries.

Near the top of the file put this:
```
?query=j0v/'/-1/!docker run --rm -i justin2004/sparql_pretty:noh
```





Visidata has installation instructions [here](https://github.com/saulpw/visidata).

Then put this into `~.visidatarc`:
```python
def get_qname(uri):
    # TODO perhaps build this from a .ttl file
    PREFIXES={
    'http://www.bbc.co.uk/ontologies/bbc/':'bbc',
    'http://www.bbc.co.uk/ontologies/coreconcepts/':'core',
    'http://www.bbc.co.uk/ontologies/creativework/':'cwork',
    'http://purl.org/dc/elements/1.1/':'dc',
    'http://purl.org/dc/terms/':'dcterms',
    'http://www.w3.org/2002/07/owl#':'owl',
    'http://www.bbc.co.uk/ontologies/provenance/':'provenance',
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#':'rdf',
    'http://www.w3.org/2000/01/rdf-schema#':'rdfs',
    'http://www.bbc.co.uk/ontologies/tagging/':'tagging',
    'http://www.w3.org/2001/XMLSchema#':'xsd'
    }
    for prefix in PREFIXES.keys():
        if uri.startswith(prefix):
            return uri.replace(prefix, PREFIXES[prefix] + ":")
    return uri

def to_uri():
    TMUX_RDF_SESSION='ontology'
    subprocess.run(['tmux','switch-client','-t',TMUX_RDF_SESSION])
    uri = get_qname(vd.sheet.cursorCell.value)
    subprocess.run(['tmux','send-keys','-t',TMUX_RDF_SESSION,':tsel ' + uri , 'Enter', '1','Enter'])

BaseSheet.addCommand('3', 'go-to-uri', 'to_uri()')
```

That defines a visidata command a binds the key `3` to it.
You can change the key of course.

When your cursor is on a cell with a URI in it you can press `3` to jump to the tmux "ontology" session and find that keyword.



---


https://www.bbc.co.uk/ontologies/documents/creativework.ttl
https://www.bbc.co.uk/ontologies/documents/bbc.ttl
https://www.dublincore.org/specifications/dublin-core/dcmi-terms/dublin_core_terms.ttl

# GOOD!
http://www.w3.org/2002/07/owl#
http://www.w3.org/1999/02/22-rdf-syntax-ns#
http://www.w3.org/2000/01/rdf-schema#
