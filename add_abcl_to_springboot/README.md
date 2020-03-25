## adding a lisp interpreter to a spring boot application

ABCL ([Armed Bear Common Lisp](https://common-lisp.net/project/armedbear/)) is an implementation of Common Lisp that runs on the JVM. I really like the REPL style development so I wanted to bring that to the Java application (using Spring Boot) I am working on.


The first problem I encountered: the classloader

"The Spring Boot Maven and Gradle plugins both package our application as executable JARs – such a file can't be used in another project since class files are put into BOOT-INF/classes. This is not a bug, but a feature." [](https://www.baeldung.com/spring-boot-dependency)

```
CL-USER> (jss:japropos "String")
...
sun.swing.StringUIClientPropertyKey: Java Class
sun.text.normalizer.ReplaceableString: Java Class
...
```


```
CL-USER> (jclass "java.lang.String")
#<java class java.lang.String>
```

```
CL-USER> (jss:japropos "Application")
BOOT-INF.classes.com.khoubyari.example.Application: Java Class
```

```
CL-USER> (jclass "BOOT-INF.classes.com.khoubyari.example.Application")
; Evaluation aborted on NIL
```

```
(jclass "com.khoubyari.example.Application")
Class not found: com.khoubyari.example.Application
   [Condition of type ERROR]
```


The default classloader won't load them.
I briefly tried to instantiate and use a URLClassLoader (like Spring does) but that didn't work for me.

The way I got around this problem was to make a pom.xml with all the dependencies I want to be able to use from Lisp and from Java and then I put that resultant jar file on the classpath.

To demonstrate this I started with an existing Spring Boot application and on my [fork](https://github.com/justin2004/spring-boot-rest-example) (see the last few commits) I added a Lisp interpreted and loaded swank so I could explore and make changes to the live application.


If you have [docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/) installed you can: 

0) clone my fork
0) `docker-compose up`
0) use a slime client to connect to the swank server running on the JVM in the docker container
