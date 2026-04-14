# Train Trees


## Motivation

Near the end of [ArrayCast episode 121](https://www.youtube.com/watch?v=lBrczam-Dvk) there was a desire for feedback about binding strength of tacit expressions in APL.

It was noted that sometimes it is hard "to see how far things reach."
Operators have long left scope and functions have long right scope and perhaps the long left scope is less intuitive.

In Dyalog APL, I find that looking at train trees is more than sufficient for getting binding strength and train syntax feedback.

They are enabled with:

```
]box on -trains=tree
```

I don't see the need for any other binding strength visual feedback system as I hope to demonstrate below.


## Quick Lesson

To read train trees you need to understand the building blocks: 2 trains and 3 trains.
Let's only consider monadic trains (taking 1 argument) for now.

### 2 Trains

If you are new to APL when you are chaining together functions in APL you are mostly doing this atop that, atop this, etc.
Like a unix shell pipeline.

As a train tree an "atop" is a 2 train  `┌┴┐`.

e.g.

```apl
      ⌽∊
┌┴┐
⌽ ∊
```

That means, do the `⌽` atop `∊`.
In other words, first do the `∊` then atop that do the `⌽`.

As a unix shell command that might look like: `∊ some_file | ⌽`.

So while reading a 2 train sub-tree, you need to start at the right tine first as it logically happens first.

Evalaute this `(⌽∊) (1 2) (3 4)` on [tryapl.org](https://tryapl.org/) to get a sense for 2 trains.

### 3 Trains

Next we have the 3 train (a fork) `┌─┼─┐`.

e.g.

```apl
      +/÷≢
  ┌─┼─┐
  / ÷ ≢
┌─┘    
+ 
```

That means, start at the outer tines... 

- take the `≢` of the argument
- take the `+/` of the argument
- then pass those results "up" to the `÷` (the middle tine function gets applied dyadically (2 arguments))

Note that since `/` is an operator it alters the shape of the tree by grabbing `+` as its function operand.

Evalaute this `(+/÷≢) 1 2 3` on [tryapl.org](https://tryapl.org/) to get a sense for 3 trains.


Finally, sometimes you want to force an "atop" (2 train).
You can do that with the atop operator `⍤`.

e.g.

```apl
      +/÷⍤≢
  ┌┴─┐ 
  /  ⍤ 
┌─┘ ┌┴┐
+   ÷ ≢
```

Notice I took the 3 train from above but since I added `⍤` it changed the outermost train from a 3 train into a 2 train.
Also, like we asked, it made `÷≢` a 2 train (an atop) lower in the tree.

That function says:

- take the `≢` of the argument
  - then atop that apply `÷` (to get the recriprocol)
    - then atop that apply `+/` (which will sum a single scalar) 

It's not an interesting function but we are just learning what the shapes of trees mean.


So in general, start at the lowest parts of the tree and apply the rules for 2 and 3 trains as you approach the root of the tree.


## Example

Recently I needed to write a Root Mean Square function.
I am using that function on a vector of PCM audio samples.

![](media/RMS.png)


I first wrote the RMS function like this:

```apl
*∘0.5⍤(+/*∘2÷≢)
```

Which has this corresponding train tree

```apl
     ⍤
 ┌───┴────┐
 ∘      ┌─┴─┐
┌┴┐     / ┌─┼─┐
* 0.5 ┌─┘ ∘ ÷ ≢
      +  ┌┴┐
         * 2
```

That tells us that our tacit function is equivalent to the explicit function:

```apl
{((+/ ((⍵ * 2) ÷ (≢ ⍵))) * 0.5)}
```

I mostly develop tacit functions by looking at the train tree as I go.
Train trees are not just a "cute" representation of a tacit function.
They are a depiction of the application of [binding strength](https://docs.dyalog.com/20.0/programming-reference-guide/introduction/binding-strength/) and train syntax over the whole tacit function.


Looking at the train tree, I noticed that the division function `÷` is "lower" in the tree than the sum reduction `+/`.
It is "lower" because in a 2 tine train `┌─┴─┐` the left tine is done [atop](https://aplwiki.com/wiki/Train#2-trains) the right tine.

That means this function will do the division once per item in the argument.

Instead, let's make the division happen once.

```apl
*∘0.5 (+/*∘2)÷≢

 ┌────┴────┐
 ∘     ┌───┼─┐
┌┴┐   ┌┴─┐ ÷ ≢
* 0.5 /  ∘
    ┌─┘ ┌┴┐
    +   * 2
```

In this function, the division is "above" the sum reduction `+/` because it is in the middle tine of a 3 train `┌─┼─┐`. 
The middle tine of a [3 train](https://aplwiki.com/wiki/Train#3-trains) is done between the outer tines.
So now the division will only happen once.


Now, you might wonder if we can remove the parens in that function.
Let's try.

```apl
*∘0.5+/*∘2÷≢

 ┌──────┼───┐
 ∘      / ┌─┼─┐
┌┴┐   ┌─┘ ∘ ÷ ≢
* 0.5 +  ┌┴┐
         * 2
```

Notice the tree changes its shape.
Before we had an outermost 2 train `┌─┴─┐` but now we have an outermost 3 train `┌─┼─┐`
Although we can often remove parens and the binding strength application does what you intend (without the guidance of parens), in this case we can't remove the parens.


As I was developing the function `*∘0.5 (+/*∘2)÷≢` I initially used some parens...

```apl
*∘0.5 ((+/*∘2)÷≢)

 ┌────┴────┐
 ∘     ┌───┼─┐
┌┴┐   ┌┴─┐ ÷ ≢
* 0.5 /  ∘
    ┌─┘ ┌┴┐
    +   * 2
```

But I noticed removing those parens didn't change the train tree.
I find that developing like this is helping with parsing the linear representation of tacit functions in my mind.

Often I start a tacit function by using parens to make the components of the train clear to me (in the linear representation) but then I see which are unnecessary by looking at the train tree after I delete them. 

Also, I sometimes write APL on paper by using the train tree representation.
That makes it pretty easy to later type it out in the linear representation for the interpreter.



### Related Resources

https://www.hillelwayne.com/handwriting-j/

https://www.reddit.com/r/apljk/comments/1ohvf0s/handwriting_programs_in_j/

train tree printing function is defined [here](https://dfns.dyalog.com/n_dft.htm)
