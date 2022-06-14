# How it feels to use APL
## We are spelling we are creating bonds


## APL 

APL is A Programming Language.
It works quite well when you are working with rectangular data.

I've used it to teach image processing to students.

In APL the number of primitives (functions and operators) you need to know is pretty small.
Each primitive consists of a single character.

Here they are:
```
! * < = > ? | ~ ¨ ¯ × ÷ ← ↑ → ↓ ∆ ∇ ∊ ∘ 
∧ ∨ ∩ ∪ ≠ ≡ ≢ ≤ ≥ ⊂ ⊃ ⊆ ⊖ ⊢ ⊣ ⊤ ⊥ ⋄ ⌈ ⌊ 
⌷ ⌸ ⌹ ⌺ ⌽ ⌿ ⍀ ⍉ ⍋ ⍎ ⍒ ⍕ ⍙ ⍝ ⍞ ⍟ ⍠ ⍣ ⍤ ⍥ 
⍨ ⍪ ⍫ ⍬ ⍱ ⍲ ⍳ ⍴ ⍵ ⍷ ⍸ ⍺ ⎕ ○
```

Entering the characters on a standard keyboard is not a problem. TODO

## What Is APL Though?

"Is [APL] just a set of well-chosen matrix operators?"
https://news.ycombinator.com/item?id=17173283

APL does have a well-chosen set of matrix operators.
The coverage feels like it approaches a periodic table of chemical behavior.
but there is more to the language.

https://news.ycombinator.com/item?id=17186470



## How it feels to use it

To me, programming in APL feels different than programming in other languages I know.
To me, programming in APL feels like designing molecules.
I've never designed a molecule so this blog post is highly evocative and based on subjective impressions and associations.




If you want to invoke or reference a function in most programming languages you have to spell the name of the function.
Often APL programmers talk of "the spelling of a function in APL" but they mean something different.

APL programmers might say "arithmetic mean (or average) is spelled `+/÷≢` in APL"

An APL expression is like a spelling in that those are the typographical items that you string together.
But it could also be considered something like a [structural formula](https://en.wikipedia.org/wiki/Structural_formula) of a computational process.
A structural formula of a molecule shows how the constituent atoms (primitives) are bonded together.
An APL expression shows how the language primitives are bonded together.

In fact, if you express a function in a Dyalog APL REPL you'll see a tree rendering of the derived function.
The tree diagrams of derived functions are one way [Dyalog APL]() renders the bonding of primitives in what it calls [trains]().
Those tree diagrams and structural formulas (like the image below) are helpful for visualizing how the molecule's parts contribute to the whole which will interact with its surroundings (arguments or chemical entities, respectively).

(reference image)

Let's look at an example.
Let's say you want to put a comma between each item in a sequence.
In Clojure we can use `interpose` to do that. 
The Clojure core has already assigned a function to that name.

```clojure
(interpose "," (range 1 10))
=> (1 "," 2 "," 3 "," 4 "," 5 "," 6 "," 7 "," 8 "," 9)
```

You can also assign functions to names in APL.
```
      average←+/÷≢
      average 1 2 3
2
```

In Clojure you spell the name of the function ("interpose" in this example).
But `interpose` is just a name and interpose itself is really [elsewhere](https://github.com/clojure/clojure/blob/master/src/clj/clojure/core.clj#L5231).

It isn't really convenient to break Clojure's interpose into pieces and re-mix the parts to do something different.
It is intended that interpose is one of your primitives.

In APL you reference interpose behavior directly (without going through a name):

```apl
      1↓,',',⍪⍳9
1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
```
All the parts of APL's interpose are exposed and the re-mixing potential is immediate.

Let's step through that APL expression (in APL evaluation is right to left).

[iota]() 9

```
      ⍳9
      1 2 3 4 5 6 7 8 9
```

Let's think of that as the argument and what we do next as the interpose behavior.

[table]() it

```
      ⍪⍳9
1
2
3
4
5
6
7
8
9
```

[catenate]() the character ',' onto the matrix (with [scalar extension](https://aplwiki.com/wiki/Scalar_extension)) 

```
      ',',⍪⍳9
, 1
, 2
, 3
, 4
, 5
, 6
, 7
, 8
, 9
```

[ravel]() it

```
      ,',',⍪⍳9
, 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
```

1 [drop]() to remove the unwanted leading comma

```
      1↓,',',⍪⍳9
1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9
```

Sometimes you just build an expression up like this and you're done.

But the resultant expression isn't a function so you can't name it, pass actual arguments to it, etc.
```
      1↓,',',⍪
      SYNTAX ERROR: Missing right argument
```

But you could turn that expression into a function (in this case by using ∘ [bind]()).

```
      1∘↓∘,','∘,∘⍪
  ┌─┴─┐ 
  ∘   ∘ 
 ┌┴┐ ┌┴┐
 ∘ , ∘ ⍪
┌┴┐ ┌┴┐ 
1 ↓ , , 
```


Also here is another way to express interpose with an APL function:

```
      (⊣,',',⊢)/
    /    
  ┌─┘    
┌─┼───┐  
⊣ , ┌─┼─┐
    , , ⊢
```


## summary so far?

In APL it feel like you are making molecules with atoms (language primitives) and bonds (combinators/trains).
In APL the spelling of the name of the molecule _is_ the molecule.
In APL the name isn't a layer of indirection; it is directly the entity.

## remix


Instead of 1,2,3,4,5,6,7,8,9 what if i want 1 2 , 3 4 , 5 6 , 7 8

In Clojure you could reference, by name, another function: `partition`.

(interpose "," (partition 2 (range 1 10)))
=> ((1 2) "," (3 4) "," (5 6) "," (7 8))

Close enough.

<!-- In APL you can get partition behavior with ⍴ (reshape) and a train to compute the desired shape. -->
In APL you can get partition behavior by reshaping the vector into a matrix.
We use a train to compute the desired shape of the matrix.
You'll notice that in trains you don't reference arguments explicitly.
Trains are a form of tacit programming.

Here is the train to compute the desired shape:
```
      (,∘2)(⌊÷∘2)
 ┌─┴─┐  
 ∘  ┌┴┐ 
┌┴┐ ⌊ ∘ 
, 2  ┌┴┐
     ÷ 2
```


And then we embed that train into another train:
```
      (((,∘2)(⌊÷∘2))⍴⍳)
   ┌───┼─┐
 ┌─┴─┐ ⍴ ⍳
 ∘  ┌┴┐   
┌┴┐ ⌊ ∘   
, 2  ┌┴┐  
     ÷ 2 
```

Then we just need to follow up with the expression (that we used a moment ago):
```
      1↓,',',
```

Which will:

- catenate (left and right argument given to `,`): concatenate the comma onto each row of the matrix
- ravel (right argument given to `,`): turn the matrix into a vector
- drop (right argument given to `↓`): drop the leading comma


All together:
```
      1↓,',',(((,∘2)(⌊÷∘2))⍴⍳) 9
1 2 , 3 4 , 5 6 , 7 8
```





"is APL just a well chosen set of primitives?" hackernews
the single char primitives mean you have less to overcome to express something.
kids do almost anything with cheerfulness and i think that is partially due to fact that they have little to overcome to act.
they aren't tired.
they have energy.
they don't believe the action is of little value.

re-arranging single chars is faster.
