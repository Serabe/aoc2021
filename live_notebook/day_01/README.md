<!-- livebook:{"persist_outputs":true} -->

# Day 01: Sonar Sweep.

## First Star

As the submarine drops below the surface of the ocean, it automatically performs a sonar sweep of the nearby sea floor. On a small screen, the sonar sweep report (your puzzle input) appears: each line is a measurement of the sea floor depth as the sweep looks further and further away from the submarine.

For example, suppose you had the following report:

```
199
200
208
210
200
207
240
269
260
263
```

This report indicates that, scanning outward from the submarine, the sonar sweep found depths of 199, 200, 208, 210, and so on.

The first order of business is to figure out how quickly the depth increases, just so you know what you're dealing with - you never know if the keys will get carried into deeper water by an ocean current or a fish or something.

To do this, count the number of times a depth measurement increases from the previous measurement. (There is no measurement before the first measurement.) In the example above, the changes are as follows:

```
199 (N/A - no previous measurement)
200 (increased)
208 (increased)
210 (increased)
200 (decreased)
207 (increased)
240 (increased)
269 (increased)
260 (decreased)
263 (increased)
```

In this example, there are 7 measurements that are larger than the previous measurement.

How many measurements are larger than the previous measurement?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
```

```output
[199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
```

We need to work out the differences. For that, we need to get the pairs `[176, 184]`, `[184, 188]`, and so on.
For that, `Enum.chunk_every\4` seems pretty useful, as it let us do nifty things like the following:

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
IO.inspect(Enum.chunk_every(1..5, 2, 2))
IO.inspect(Enum.chunk_every(1..5, 2, 2, :discard))
IO.inspect(Enum.chunk_every(1..5, 2, 1))
IO.inspect(Enum.chunk_every(1..5, 2, 3))
```

```output
[[1, 2], [3, 4], [5]]
[[1, 2], [3, 4]]
[[1, 2], [2, 3], [3, 4], [4, 5], [5]]
[[1, 2], [4, 5]]
```

```output
[[1, 2], [4, 5]]
```

Thus, we just need to do `Enum.chunk_every(input, 2, 1, :discard)` to get what we want.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
pairs = Enum.chunk_every(input, 2, 1, :discard)
```

```output
[
  [199, 200],
  [200, 208],
  [208, 210],
  [210, 200],
  [200, 207],
  [207, 240],
  [240, 269],
  [269, 260],
  [260, 263]
]
```

Finally, we substract the second element to the first and then filter and count.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
pairs |> Enum.map(fn [a, b] -> b - a end) |> Enum.filter(&(&1 > 0)) |> Enum.count()
```

```output
7
```

In this case, we might rather use the `Stream` module, that does not create a new array for each step.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> Stream.chunk_every(2, 1, :discard)
|> Stream.map(fn [a, b] -> b - a end)
|> Stream.filter(&(&1 > 0))
|> Enum.count()
```

```output
7
```

## Second Star

Considering every single measurement isn't as useful as you expected: there's just too much noise in the data.

Instead, consider sums of a three-measurement sliding window. Again considering the above example:

```
199  A      
200  A B    
208  A B C  
210    B C D
200  E   C D
207  E F   D
240  E F G  
269    F G H
260      G H
263        H
```

Start by comparing the first and second three-measurement windows. The measurements in the first window are marked A (199, 200, 208); their sum is 199 + 200 + 208 = 607. The second window is marked B (200, 208, 210); its sum is 618. The sum of measurements in the second window is larger than the sum of the first, so this first comparison increased.

Your goal now is to count the number of times the sum of measurements in this sliding window increases from the previous sum. So, compare A with B, then compare B with C, then C with D, and so on. Stop when there aren't enough measurements left to create a new three-measurement sum.

In the above example, the sum of each three-measurement window is as follows:

```
A: 607 (N/A - no previous sum)
B: 618 (increased)
C: 618 (no change)
D: 617 (decreased)
E: 647 (increased)
F: 716 (increased)
G: 769 (increased)
H: 792 (increased)
```

In this example, there are 5 sums that are larger than the previous sum.

Consider sums of a three-measurement sliding window. How many sums are larger than the previous sum?

<!-- livebook:{"break_markdown":true} -->

In this case, we need to transform the `input` a bit first.
We already know `Enum.chunk_every/4` so we can use it to the first part, the sliding window.
Then, just a `Enum.map(&Enum.sum/1`) would be enough.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
# Add three consecutive elements
|> Enum.chunk_every(3, 1, :discard)
|> Enum.map(&Enum.sum/1)
# Same as first star
|> Enum.chunk_every(2, 1, :discard)
|> Enum.map(fn [a, b] -> b - a end)
|> Enum.filter(&(&1 > 0))
|> Enum.count()
```

```output
5
```

We can also use `Stream` here.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
# Add three consecutive elements
|> Stream.chunk_every(3, 1, :discard)
|> Stream.map(&Enum.sum/1)
# Same as first star
|> Stream.chunk_every(2, 1, :discard)
|> Stream.map(fn [a, b] -> b - a end)
|> Stream.filter(&(&1 > 0))
|> Enum.count()
```

```output
5
```
