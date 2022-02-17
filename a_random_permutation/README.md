# A Random Permutation

The other day I needed to pick a random order for my team to present our work in.
Usually one of us just makes up an order but this time I decided to do it programmatically.

With my team on the call, I fired up an [APL REPL](https://tryapl.org/) and entered an expression like:

```apl
      'alice' 'bob' 'yazeed' 'zach'[4?4]
┌─────┬────┬──────┬───┐
│alice│zach│yazeed│bob│
└─────┴────┴──────┴───┘
```

So with 4 characters, `[4?4]`, I had the business end of an expression to select a random permutation. 
But in that expression I have to manually count the number of people on my team (4) and type it two times.
Let's see if we can eliminate that so I can add people and have the expression handle it.

```apl
      {⍵[?⍨≢⍵]} 'alice' 'bob' 'yazeed' 'zach'
┌────┬──────┬─────┬───┐
│zach│yazeed│alice│bob│
└────┴──────┴─────┴───┘
```

So with 9 characters I had a function to handle a group of any size.

If some NASA Apollo program contributors join my team I can handle them:
```apl
      {⍵[?⍨≢⍵]} 'alice' 'bob' 'yazeed' 'zach' 'margaret' 'fred' 'jim' 'jack'
┌────┬──────┬───┬───┬────┬────┬─────┬────────┐
│zach│yazeed│bob│jim│jack│fred│alice│margaret│
└────┴──────┴───┴───┴────┴────┴─────┴────────┘
```

But that expression explicitly references the parameter (⍵) two times.
There is another way to do this that does not involve explicitly referencing the parameters: [tacit style](https://en.wikipedia.org/wiki/Tacit_programming)

```apl
      (⊂⍤?⍨∘≢⌷⊢) 'alice' 'bob' 'yazeed' 'zach'
┌──────┬───┬────┬─────┐
│yazeed│bob│zach│alice│
└──────┴───┴────┴─────┘
```

Notice that that expression does not reference its parameters explicitly (⍵ and ⍺ do not occur in the expression).
It is only 8 characters (if you don't count the parens which are only there because I put the argument (the vector of character vectors) next to it.)

I don't expect that many other languages can express this in 8 characters or less (especially without a library)!

I've only been using APL recreationally ([contributing to April](https://github.com/phantomics/april)) for about a year but I was able to arrive at the first two expressions quickly.
The tacit style took me at least 10 minutes and I had help from [The APLcart](https://aplcart.info/).
(I didn't make my team watch me try to write this tacit style expression; I did it after work.)

I knew I wanted a permutation of a vector of character vectors so I searched "permutation" in APLcart and I found the following (which is the basis of the tacit expression I wrote):
```
Iv⌷⍨∘⊂⍨Y              Permute: Reorder major cells of Y according tot permutation vector Iv
```

APLcart tells you that Iv is an integer vector and Y is any array.
I won't describe the 10 minutes in detail but I'll list the things I needed to remember/review/discover in addition to the language primitives:



[Function Trains](https://help.dyalog.com/18.2/index.htm#Language/Introduction/Trains.htm?Highlight=train).
Specifically the monadic fork.

Dyalog APL's expression tree.
I actually don't know what they call it but if you type a tacit expression in the REPL it prints a cute tree representation of how the functions and operators get glued together.

```
      ⌷⍨∘⊂⍨ 
     ⍨
   ┌─┘
   ∘  
  ┌┴┐ 
  ⍨ ⊂ 
┌─┘   
⌷     
```

If APL looks interesting to you I can recommend the [Dyalog APL Tutor](https://tutorial.dyalog.com/) to get more comfortable with the language.

Ok, have fun making random orders to present your team's work in. :)
