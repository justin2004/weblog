## Design Implications (Python & APL)

Today I was using Python and I needed to concatenate some sequences.
I tried to just put a `,` in between them but that wasn't it.
Then I remembered how the design of Python, in its pursuit of readability and expressiveness, overloads `+` as numeric addition and sequence concatenation.
It does so at a cost and I don't think it is cute anymore (like I did when I first saw it).

A super thoughtful design pays for itself in ways that are hard to quantify and Python's design isn't super thoughtful with respect to overloading `+`.


## Python

In Python `+` is overloaded.
It can do arithmetic addition (for numeric operands) or concatenation (for sequence operands).

When operands are numbers we get arithmetic addition:
```python
  1 + 1
2
```

When operands are sequences we get concatenation:
```python
  [1, 2] + [3, 4]
[1, 2, 3, 4]
```

But what if you have a sequences of numbers and you want to add the numbers in the sequences?
If you want item wise addition of sequences (with numeric elements) you need more than just `+`.

You need *four* pieces of machinery (a function `zip`, a list comprehension, a `for` loop, and the `+`):

```python
  [x + y for x, y in zip([1,2,3], [1,2,3])]
[2, 4, 6]
```

## APL

In other parts of the world (Hello, Canada) we have APL.
APL was designed as a mathematical notation and as an executable language.
Ken Iverson, the designer of APL on the design of APL: ["the advantages of executability and universality found in programming languages can be effectively combined, in a single coherent language, with the advantages offered by mathematical notation."](https://www.jsoftware.com/papers/tot.htm)

In APL `+` isn't overloaded based on the types of operands like it is in Python.
`+` can handle operands that are arrays (almost everything is an array in APL).
And arrays can have zero or many dimensions.

When operands are arrays of zero dimensions (scalars).
```apl
      1+1
2
```

When an operands is an array of zero dimensions (scalar) and another is an array of one dimension.
```apl
      1+1 2 3 4
2 3 4 5
```

When both operands are arrays of one dimension.
```apl
      1 2 3 + 1 2 3
2 4 6
```

Note that in APL, item wise addition of arrays (sequences in Python speak) only required *one* piece of machinery: `+`.

And concatenation is a different glyph: `,`.

```apl
      1 2 3 , 4 5 6 
1 2 3 4 5 6
```

If you try to concatenate two character arrays with `+` in APL:
```apl
      'hello'+'goodb'
DOMAIN ERROR
      'hello'+'goodb'
             ∧
```
Because arithmetic addition isn't what you want -- you want concatenation.
```apl
      'hello','goodbye'
hellogoodbye
```

## Implications

The design of Python, in its pursuit of "readability" and "expressiveness," overloads `+` as numeric addition and sequence concatenation but at a great cost.
Sure, APL has an additional glyph to learn (`,`) if need to concatenate. 
But by introducing that glyph (at design time) and using `+` with two operands to always mean arithmetic addition, APL was able to do with 1 piece of machinery what Python needs 4 for.

That is generally the case when comparing APL and Python.

["each one of these single-character glyphs in APL when translated equates to anywhere from roughly 1 to 50 lines of Python!"](https://www.reddit.com/r/Python/comments/z7doen/i_spent_the_last_2_months_converting_apl/)


As I use Python I'll continue to wish I was able to sprinkle in APL expressions as needed.
