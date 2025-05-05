# Interfaces and Personalities

I work in the software development space and I have been noticing some patterns between the personalities and the resultant product.
In collaborative environments, such as software development, the resultant product is affected by the personality traits of the individual contributors.

I see the personalities as a tendency to focus on a particular type of interface.
Interfaces, of course, are points where two things meet and interact.

In software development the things interacting are:

- People
- Knowledge
- Needs/Wants
- Specifications
- Applications
- Execution Environments
- Serialized Data
  - Explicit
  - Implicit

We could slice up the space differently but I think this set of things aligns well with interfaces that matter.

There are interfaces between each of those things to all the other things but I think only a handful of those interfaces account for the most amount of product quality variation between software implementations.
I don't have a name for those interfaces but I have a personality that tends to focus on them:

; image

By varying the amount of attention each of these personalities put into the software product you can vary some important operational characteristics of software.

It isn't always the case that you get a person for each personality type.
Sometimes one person represents several of the personalities.
But I don't think I've ever come across a person that represents all of them.

Let's look at each of them in turn.

## Between Application and Application

The interface between applications is a focus of the personality "software developer."

Software developers focus on more than just the interface between applications but their focus on this interface is what makes the resultant software more "developer friendly."
This personality puts work into interfaces that other applications can use (APIs).
Allowing this personality to have the majority vote often results in software that this personality likes to use.
-- Circular --

X invent APIs with a mind for only their applications needs (not the needs of the ecosystem around it).

Most software that is developed is lopsided due to this personality getting too much attention.

## Between Application and Execution Environment
The interface between applications and execution environments: "DevOps engineer"

Without some attention to this interface you'll likely get an application that won't easily run in other execution environments.

## Between Application and Serialized Data
The interface between Applications and Serialized Data is a focus of the personality: "Data Engineer"

When you think of enterprise software that almost always entails some kind of ETL (extracting, transforming, and loading data).
This is the domain of the data engineer personality.

## Between Serialized Data (explicit) and Serialized Data (implicit)

Serialized Data (explicit) and Serialized Data (implicit): "Data Scientist"

This is the personality that is doing AI/ML.
This work is about taking some input (serialized data) and doing some computations and producing some output (serialized data).
Most often the output data is implicit in that it was derivable from the input but the input did not explicitly state it.
e.g. From the input "Owen has 2 apples. He gives 1 to his dad." you can derive "Owen now has 1 apple" as it is an implicit fact based on the input.

To do useful derivations (that weren't easily obtained) you often need multiple different input data sources.
You can use any mechanism to produce these derivations: algebra, regression analysis, deductive logic, artificial neural networks, and LLMs.

This personalty is often told to "produce insights."


## Between Knowledge and Serialized Data

Knowledge and Serialized Data: "Applied Ontologist"

This personality is the most under represented in software development and it results in systems that work for a narrow purposes and does not adapt well to variations on those purposes and new purposes.

When this personality is under represented you get software that:
- has data schemata for its narrow purposes
- is stove piped ?
- entangles serialized data and code
  - such that it is hard to migrate data out of one system and into another
- entangles the meaning of serialized data with the code that handles it
- assumes you'll be the one doing the ETL to get data in and out
