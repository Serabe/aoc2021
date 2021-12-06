# Day 3: Binary Diagnostic

## First star

The submarine has been making some odd creaking noises, so you ask it to produce a diagnostic report just in case.

The diagnostic report (your puzzle input) consists of a list of binary numbers which, when decoded properly, can tell you many useful things about the conditions of the submarine. The first parameter to check is the power consumption.

You need to use the binary numbers in the diagnostic report to generate two new binary numbers (called the gamma rate and the epsilon rate). The power consumption can then be found by multiplying the gamma rate by the epsilon rate.

Each bit in the gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report. For example, given the following diagnostic report:

```
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
```

Considering only the first bit of each number, there are five 0 bits and seven 1 bits. Since the most common bit is 1, the first bit of the gamma rate is 1.

The most common second bit of the numbers in the diagnostic report is 0, so the second bit of the gamma rate is 0.

The most common value of the third, fourth, and fifth bits are 1, 1, and 0, respectively, and so the final three bits of the gamma rate are 110.

So, the gamma rate is the binary number 10110, or 22 in decimal.

The epsilon rate is calculated in a similar way; rather than use the most common bit, the least common bit from each position is used. So, the epsilon rate is 01001, or 9 in decimal. Multiplying the gamma rate (22) by the epsilon rate (9) produces the power consumption, 198.

Use the binary numbers in your diagnostic report to calculate the gamma rate and epsilon rate, then multiply them together. What is the power consumption of the submarine? (Be sure to represent your answer in decimal, not binary.)

```elixir
input = [
  "00100",
  "11110",
  "10110",
  "10111",
  "10101",
  "01111",
  "00111",
  "11100",
  "10000",
  "11001",
  "00010",
  "01010"
]
```

In this case, we are going to start with a module for counting freqs and returning the more common bit.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Freq do
  def add_freq("0", {zeros, ones}), do: {zeros + 1, ones}
  def add_freq("1", {zeros, ones}), do: {zeros, ones + 1}
  def add_freq(_, freq), do: freq

  def common({zeros, ones}) when zeros > ones, do: 0
  def common({_zeros, _ones}), do: 1

  def uncommon({zeros, ones}) when zeros <= ones, do: 0
  def uncommon({_zeros, _ones}), do: 1
end
```

`add_freq` receives a bit (as a string) and updates the frequency.

`common` returns the most common bit value according to the frequencies.

`uncommon` returns the least commong bit value according to the frequencies.

For the cases when both frequencies match we will use the strategy explained later in the second star.

<!-- livebook:{"break_markdown":true} -->

Now, we need to init an array of frequencies.
We will use the first input to initialize it, but only checking the length,
as the test input has fewer bits that the actual input.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
init_freqs = fn first ->
  1..String.length(first) |> Enum.map(fn _ -> {0, 0} end)
end
```

We will now need a method to update the array of frequencies given a new input line.

```elixir
update_freqs = fn freqs, input ->
  input
  |> String.split("", trim: true)
  |> Enum.zip(freqs)
  |> Enum.map(fn {d, freq} -> Freq.add_freq(d, freq) end)
end
```

We use `Enum.zip/2` to match each freq to the bit of the new input.

<!-- livebook:{"break_markdown":true} -->

We will have a `run1/2` method that will be recursive (`run/1` will set it up).
`run1/2` will have two overloads.
The first one will be the base case, that will work out both _gamma_ and _epsilon_ rates and return the result.
The second one will just recur.

<!-- livebook:{"break_markdown":true} -->

`run/1` will just set up the initial arguments for `run1/2`.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Day03FirstStar do
  def init_freqs(first), do: 1..String.length(first) |> Enum.map(fn _ -> {0, 0} end)

  def update_freqs(freqs, input) do
    input
    |> String.split("", trim: true)
    |> Enum.zip(freqs)
    |> Enum.map(fn {d, freq} -> Freq.add_freq(d, freq) end)
  end

  def run(input) do
    case input do
      [h | _t] -> run1(input, init_freqs(h))
      _ -> 0
    end
  end

  def run1([], freqs) do
    gamma_rate = freqs |> Enum.map(&Freq.common/1) |> Integer.undigits(2)
    epsilon_rate = freqs |> Enum.map(&Freq.uncommon/1) |> Integer.undigits(2)

    gamma_rate * epsilon_rate
  end

  def run1([h | t], freqs), do: run1(t, update_freqs(freqs, h))
end
```

```elixir
Day03FirstStar.run(input)
```

Yay!

## Second Star

Next, you should verify the life support rating, which can be determined by multiplying the oxygen generator rating by the CO2 scrubber rating.

Both the oxygen generator rating and the CO2 scrubber rating are values that can be found in your diagnostic report - finding them is the tricky part. Both values are located using a similar process that involves filtering out values until only one remains. Before searching for either rating value, start with the full list of binary numbers from your diagnostic report and consider just the first bit of those numbers. Then:

* Keep only numbers selected by the bit criteria for the type of rating value for which you are searching. Discard numbers which do not match the bit criteria.
* If you only have one number left, stop; this is the rating value for which you are searching.
* Otherwise, repeat the process, considering the next bit to the right.

The bit criteria depends on which type of rating value you want to find:

* To find oxygen generator rating, determine the most common value (0 or 1) in the current bit position, and keep only numbers with that bit in that position. If 0 and 1 are equally common, keep values with a 1 in the position being considered.
* To find CO2 scrubber rating, determine the least common value (0 or 1) in the current bit position, and keep only numbers with that bit in that position. If 0 and 1 are equally common, keep values with a 0 in the position being considered.

For example, to determine the oxygen generator rating value using the same example diagnostic report from above:

* Start with all 12 numbers and consider only the first bit of each number. There are more 1 bits (7) than 0 bits (5), so keep only the 7 numbers with a 1 in the first position: 11110, 10110, 10111, 10101, 11100, 10000, and 11001.
* Then, consider the second bit of the 7 remaining numbers: there are more 0 bits (4) than 1 bits (3), so keep only the 4 numbers with a 0 in the second position: 10110, 10111, 10101, and 10000.
* In the third position, three of the four numbers have a 1, so keep those three: 10110, 10111, and 10101.
* In the fourth position, two of the three numbers have a 1, so keep those two: 10110 and 10111.
* In the fifth position, there are an equal number of 0 bits and 1 bits (one each). So, to find the oxygen generator rating, keep the number with a 1 in that position: 10111.
* As there is only one number left, stop; the oxygen generator rating is 10111, or 23 in decimal.

Then, to determine the CO2 scrubber rating value from the same example above:

* Start again with all 12 numbers and consider only the first bit of each number. There are fewer 0 bits (5) than 1 bits (7), so keep only the 5 numbers with a 0 in the first position: 00100, 01111, 00111, 00010, and 01010.
* Then, consider the second bit of the 5 remaining numbers: there are fewer 1 bits (2) than 0 bits (3), so keep only the 2 numbers with a 1 in the second position: 01111 and 01010.
* In the third position, there are an equal number of 0 bits and 1 bits (one each). So, to find the CO2 scrubber rating, keep the number with a 0 in that position: 01010.
* As there is only one number left, stop; the CO2 scrubber rating is 01010, or 10 in decimal.

Finally, to find the life support rating, multiply the oxygen generator rating (23) by the CO2 scrubber rating (10) to get 230.

Use the binary numbers in your diagnostic report to calculate the oxygen generator rating and CO2 scrubber rating, then multiply them together. What is the life support rating of the submarine? (Be sure to represent your answer in decimal, not binary.)

<!-- livebook:{"break_markdown":true} -->

This is way easier than the first iteration.
First, we are going to write a function
that will work out the bit frequencies on just one position
for all the input lines.

```elixir
freqs_on_bit = fn input, bit_pos ->
  input
  |> Stream.map(&Enum.at(&1, bit_pos))
  |> Enum.reduce({0, 0}, &Freq.add_freq/2)
end
```

Since we are using `Enum.at/2` here, we need for each line to be split into each bit, so...

```elixir
split_input = fn input ->
  Enum.map(input, &String.split(&1, "", trim: true))
end
```

With `freqs_on_bit/2`, we can follow the following algorithm:

1. Work out the frequencies for a given bit position.
2. Use the criteria to check which bit to match.
3. Recur with:
   1. The input filtered only to those values whose bit in the given position is the same as the one worked out in 2.
   2. The next bit position

If we take a look at the info above we see we need three arguments:

1. The input, an array of lines.
2. The criteria to look for the bit to match.
3. The bit position we are looking at.

Given it is a recursive function and there is no anonymous recursive function in Elixir,
we will need to pass the function as the first argument.

```elixir
find_complex_rating = fn
  _recur, [el], _criteria, _bit_pos ->
    el |> Enum.join() |> String.to_integer(2)

  recur, input, criteria, bit_pos ->
    freq = freqs_on_bit.(input, bit_pos)
    bit_to_match = freq |> criteria.() |> Integer.to_string()

    recur.(
      recur,
      Enum.filter(input, fn el -> Enum.at(el, bit_pos) == bit_to_match end),
      criteria,
      bit_pos + 1
    )
end
```

Finally, `run2/1` will just work out both rates and return the product.

```elixir
run2 = fn input ->
  splitted_input = split_input.(input)

  oxygen_generator_rating =
    find_complex_rating.(find_complex_rating, splitted_input, &Freq.common/1, 0)

  co2_generator_rating =
    find_complex_rating.(find_complex_rating, splitted_input, &Freq.uncommon/1, 0)

  oxygen_generator_rating * co2_generator_rating
end

run2.(input)
```
