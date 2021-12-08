# Day 8: Seven Segment Search

## First Star

You barely reach the safety of the cave when the whale smashes into the cave mouth, collapsing it. Sensors indicate another exit to this cave at a much greater depth, so you have no choice but to press on.

As your submarine slowly makes its way through the cave system, you notice that the four-digit seven-segment displays in your submarine are malfunctioning; they must have been damaged during the escape. You'll be in a lot of trouble without them, so you'd better figure out what's wrong.

Each digit of a seven-segment display is rendered by turning on or off any of seven segments named a through g:

```
  0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg
```

So, to render a 1, only segments c and f would be turned on; the rest would be off. To render a 7, only segments a, c, and f would be turned on.

The problem is that the signals which control the segments have been mixed up on each display. The submarine is still trying to display numbers by producing output on signal wires a through g, but those wires are connected to segments randomly. Worse, the wire/segment connections are mixed up separately for each four-digit display! (All of the digits within a display use the same connections, though.)

So, you might know that only signal wires b and g are turned on, but that doesn't mean segments b and g are turned on: the only digit that uses two segments is 1, so it must mean segments c and f are meant to be on. With just that information, you still can't tell which wire (b/g) goes to which segment (c/f). For that, you'll need to collect more information.

For each display, you watch the changing signals for a while, make a note of all ten unique signal patterns you see, and then write down a single four digit output value (your puzzle input). Using the signal patterns, you should be able to work out which pattern corresponds to which digit.

For example, here is what you might see in a single entry in your notes:

acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab |
cdfeb fcadb cdfeb cdbaf

(The entry is wrapped here to two lines so it fits; in your notes, it will all be on a single line.)

Each entry consists of ten unique signal patterns, a | delimiter, and finally the four digit output value. Within an entry, the same wire/segment connections are used (but you don't know what the connections actually are). The unique signal patterns correspond to the ten different ways the submarine tries to render a digit using the current wire/segment connections. Because 7 is the only digit that uses three segments, dab in the above example means that to render a 7, signal lines d, a, and b are on. Because 4 is the only digit that uses four segments, eafb means that to render a 4, signal lines e, a, f, and b are on.

Using this information, you should be able to work out which combination of signal wires corresponds to each of the ten digits. Then, you can decode the four digit output value. Unfortunately, in the above example, all of the digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and are more difficult to deduce.

For now, focus on the easy digits. Consider this larger example:

```
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb |
fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec |
fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef |
cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega |
efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga |
gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf |
gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf |
cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd |
ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg |
gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc |
fgae cfgab fg bagce
```

Because the digits 1, 4, 7, and 8 each use a unique number of segments, you should be able to tell which combinations of signals correspond to those digits. Counting only digits in the output values (the part after | on each line), in the above example, there are 26 instances of digits that use a unique number of segments (highlighted above).

In the output values, how many times do digits 1, 4, 7, or 8 appear?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"""
```

```output
"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe\nedbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc\nfgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg\nfbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb\naecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea\nfgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb\ndbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe\nbdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef\negadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb\ngcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
num_of_segments = [2, 3, 4, 7]

input
|> String.split("\n", trim: true)
|> Stream.map(&String.split(&1, [" | ", " "], trim: true))
|> Stream.map(&Enum.chunk_every(&1, 10))
|> Stream.flat_map(fn [_input, output] -> output end)
|> Enum.count(fn output -> Enum.member?(num_of_segments, String.length(output)) end)
```

```output
26
```

## Second Star

Through a little deduction, you should now be able to determine the remaining digits. Consider again the first example above:

```
acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
```

After some careful analysis, the mapping between signal wires and segments only make sense in the following configuration:

```
 dddd
e    a
e    a
 ffff
g    b
g    b
 cccc
```

So, the unique signal patterns would correspond to the following digits:

* `acedgfb`: `8`
* `cdfbe`: `5`
* `gcdfa`: `2`
* `fbcad`: `3`
* `dab`: `7`
* `cefabd`: `9`
* `cdfgeb`: `6`
* `eafb`: `4`
* `cagedb`: `0`
* `ab`: `1`

Then, the four digits of the output value can be decoded:

* `cdfeb`: `5`
* `fcadb`: `3`
* `cdfeb`: `5`
* `cdbaf`: `3`

Therefore, the output value for this entry is `5353`.

Following this same process for each entry in the second, larger example above, the output value of each entry can be determined:

* `fdgacbe cefdb cefbgd gcbe`: `8394`
* `fcgedb cgb dgebacf gc`: `9781`
* `cg cg fdcagb cbg`: `1197`
* `efabcd cedba gadfec cb`: `9361`
* `gecf egdcabf bgf bfgea`: `4873`
* `gebdcfa ecba ca fadegcb`: `8418`
* `cefg dcbef fcge gbcadfe`: `4548`
* `ed bcgafe cdgba cbgef`: `1625`
* `gbdfcae bgc cg cgb`: `8717`
* `fgae cfgab fg bagce`: `4315`

Adding all of the output values in this larger example produces `61229`.

For each entry, determine all of the wire/segment connections and decode the four-digit output values. What do you get if you add up all of the output values?

<!-- livebook:{"break_markdown":true} -->

This is getting tricky!

We need to figure out all the input numbers to check the output
(technically, we could stop once the output has been figured out but who cares).

The order in which we are going to do so is 1, 3, 4, 7, 8, 2, 5, 6, 0, and finally 9.

We are also going to sort the strings representing each number for easier comparison.

Let's start explaining the helper functions.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
update_tuple = fn tuple, idx, elem ->
  :erlang.setelement(idx + 1, tuple, elem)
end

update_tuple.({0, 1, 2}, 1, "a")
```

```output
{0, "a", 2}
```

`update_tuple` is a helper around `:erlang.setelement`. The reasons for creating a helper are:

1. `setelement` is horrible.
2. Originally, having the tuple being the first element was pretty helpful for the code.
3. Having a 0-based index system is useful, as that way the digits are in their own position.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_with_length = fn enum, l ->
  Enum.find(enum, fn n -> String.length(n) == l end)
end

find_with_length.(["1", "12", "123"], 3)
```

```output
"123"
```

Pretty self explanatory. Finds a string with length `l` in a collection of strings.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
number_common_letters = fn a, b ->
  a
  |> String.split("", trim: true)
  |> MapSet.new()
  |> MapSet.intersection(b |> String.split("", trim: true) |> MapSet.new())
  |> MapSet.size()
end

number_common_letters.("abcefg", "acdeg")
```

```output
4
```

`number_common_letters` find the number of common letters between two strings.
This will be the base of our algorithm for figuring out a few digits.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
parse_input_line = fn line ->
  [input, output] =
    line
    |> String.split([" | ", " "], trim: true)
    |> Enum.map(fn n ->
      n |> String.split("", trim: true) |> Enum.sort() |> Enum.join("")
    end)
    |> Enum.chunk_every(10)

  {input, output, {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
end

parse_input_line.(
  "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
)
```

```output
{["abcdefg", "bcdef", "acdfg", "abcdf", "abd", "abcdef", "bcdefg", "abef", "abcdeg", "ab"],
 ["bcdef", "abcdf", "bcdef", "abcdf"], {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}}
```

We are going to parse each line to a _3-tuple_ of the form `{output, input, digits}`.

Both `input` and `output` will be a list of sorted strings.

`digits` will be a _10-tuple_ for which each position holds the segments for that digit
or `nil` if unknown.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_one = fn {input, output, digits} ->
  {input, output, update_tuple.(digits, 1, find_with_length.(input, 2))}
end

find_four = fn {input, output, digits} ->
  {input, output, update_tuple.(digits, 4, find_with_length.(input, 4))}
end

find_seven = fn {input, output, digits} ->
  {input, output, update_tuple.(digits, 7, find_with_length.(input, 3))}
end

find_eight = fn {input, output, digits} ->
  {input, output, update_tuple.(digits, 8, find_with_length.(input, 7))}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

Finding out the digits 1, 4, 7, and 8 is straightforward (see first star).

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_two = fn {input, output, digits} ->
  four = elem(digits, 4)

  two =
    Enum.find(input, fn n ->
      String.length(n) == 5 && number_common_letters.(n, four) == 2
    end)

  {input, output, update_tuple.(digits, 2, two)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

The digit `2` is the only five-segment digit that only has 2 segments in common with the digit `4`.

```elixir
find_five = fn {input, output, digits} ->
  two = elem(digits, 2)

  five =
    Enum.find(input, fn n ->
      String.length(n) == 5 && n !== two && number_common_letters.(n, two) == 3
    end)

  {input, output, update_tuple.(digits, 5, five)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

The digit `5` is the only five-segment digit that only has 3 segments in common with the digit `2`.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_three = fn {input, output, digits} ->
  two = elem(digits, 2)
  five = elem(digits, 5)

  three =
    Enum.find(input, fn n ->
      String.length(n) == 5 && n != two && n != five
    end)

  {input, output, update_tuple.(digits, 3, three)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

The digit `3` is the remaining five-segment digit.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_six = fn {input, output, digits} ->
  one = elem(digits, 1)

  six =
    Enum.find(input, fn n ->
      String.length(n) == 6 && number_common_letters.(n, one) == 1
    end)

  {input, output, update_tuple.(digits, 6, six)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

The next digit is `6`.
It is the only six-segment digit that only has one segment in common with `1`.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_nine = fn {input, output, digits} ->
  four = elem(digits, 4)

  nine =
    Enum.find(input, fn n ->
      String.length(n) == 6 && number_common_letters.(n, four) == 4
    end)

  {input, output, update_tuple.(digits, 9, nine)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

Digit `9` is the only six-segment digit containing all segments in `4`.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
find_zero = fn {input, output, digits} ->
  six = elem(digits, 6)
  nine = elem(digits, 9)

  zero =
    Enum.find(input, fn n ->
      String.length(n) == 6 && n != six && n != nine
    end)

  {input, output, update_tuple.(digits, 0, zero)}
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

`0` is the remaining six-segment digit.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
decode_output = fn {_, output, tuple} ->
  decoder = Tuple.to_list(tuple)

  output
  |> Enum.map(fn n ->
    Enum.find_index(decoder, fn m -> m == n end)
  end)
  |> Integer.undigits()
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

For decoding the output, we create a _decoder_
(just a list with the content of the tuple holding the digits).
And then we use `Enum.find_index/2` to transform each digit to the number.

This part relies on each digit being on the same index (so the element at index 2 represents digit `2`)
and that we sorted the strings initially (so we can compare them way easier).

Finally, `Integer.undigits/1` will finish the work for us.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
finders = {
  find_zero,
  find_one,
  find_two,
  find_three,
  find_four,
  find_five,
  find_six,
  find_seven,
  find_eight,
  find_nine
}

create_decoder = fn digit_order ->
  fn line ->
    digit_order
    |> Enum.reduce(parse_input_line.(line), fn digit, acc ->
      elem(finders, digit).(acc)
    end)
    |> decode_output.()
  end
end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

Finally, we add a `create_decoder` that, given the order of digits, creates a decoder.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
decode_line = create_decoder.([1, 4, 7, 8, 2, 5, 3, 6, 9, 0])

input
|> String.split("\n", trim: true)
|> Stream.map(fn line -> decode_line.(line) end)
|> Enum.sum()
```

```output
61229
```
