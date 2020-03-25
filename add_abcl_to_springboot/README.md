## adding a lisp interpreter to a spring boot application

ABCL ([Armed Bear Common Lisp](https://common-lisp.net/project/armedbear/)) is an implementation of Common Lisp that runs on the JVM. I really like the REPL style development so I wanted to bring that to the Java application (using Spring Boot) I am working on.

--- 

The first problem I encountered: the classloader

"The Spring Boot Maven and Gradle plugins both package our application as executable JARs – such a file can't be used in another project since class files are put into BOOT-INF/classes. This is not a bug, but a feature." [0](https://www.baeldung.com/spring-boot-dependency)


Once you are at the ABCL REPL you can look up classes like:
```
CL-USER> (jss:japropos "String")
...
sun.swing.StringUIClientPropertyKey: Java Class
sun.text.normalizer.ReplaceableString: Java Class
...
```


You can get a Java class designator like:
```
CL-USER> (jclass "java.lang.String")
#<java class java.lang.String>
```

Or you can just instantiate a new object:
```
CL-USER> (jss:new "java.lang.String"
         "hello there")
#<java.lang.String hello there {3F5F99BA}>
```


But if you've made your jar file using the Spring Boot Maven plugin you'll see something like:
```
CL-USER> (jss:japropos "Application")
BOOT-INF.classes.com.khoubyari.example.Application: Java Class
```

Which you can not get a designator for using the default classloader:
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
I briefly tried to instantiate and use an "org.springframework.boot.loader.LaunchedURLClassLoader" (like Spring does) but I didn't get it to work (although in principle it should be possible, I think).

The way I got around this problem was to make a pom.xml with all the dependencies I want to be able to use from Lisp and from Java and then I put that resultant jar file on the classpath.

The key is to not start the application using the -jar flag but instead put all the jars on the classpath and then use flags to tell Spring Boot what the main class is:
```
CLASSPATH="target/spring-boot-rest-example-0.5.0.jar"
CLASSPATH="$CLASSPATH:/root/abcl-bin-1.6.0/abcl.jar"
CLASSPATH="$CLASSPATH:/mnt/shared-dependencies/target/shared-things-1.0.0-jar-with-dependencies.jar"

java -cp "$CLASSPATH" \
    -Dspring.profiles.active=test \
    -Dloader.main=com.khoubyari.example.Application \
    org.springframework.boot.loader.PropertiesLauncher
```

To demonstrate this I started with an existing Spring Boot application and on my [fork](https://github.com/justin2004/spring-boot-rest-example) (see the last few commits) I added a Lisp interpreted and loaded swank so I could explore and make changes to the live application.


If you have [docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/) installed you can: 

0) clone my fork
0) `docker-compose up`
0) use a slime client to connect to the swank server running on the JVM in the docker container



TODO demonstrate using the application and slime
