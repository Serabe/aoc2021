<!-- livebook:{"persist_outputs":true} -->

# Day 5: Hydrothermal Venture

## First Star

You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

```
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
```

Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

* An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
* An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.

For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

So, the horizontal and vertical lines from the above list would produce the following diagram:

```
.......1..
..1....1..
..1....1..
.......1..
.112111211
..........
..........
..........
..........
222111....
```

In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

Consider only horizontal and vertical lines. At how many points do at least two lines overlap?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"""
```

```output
"0,9 -> 5,9\n8,0 -> 0,8\n9,4 -> 3,4\n2,2 -> 2,1\n7,0 -> 7,4\n6,4 -> 2,0\n0,9 -> 2,9\n3,4 -> 1,4\n0,0 -> 8,8\n5,5 -> 8,2\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> String.split("\n", trim: true)
|> Stream.map(fn line ->
  line
  |> String.split(" -> ", trim: true)
  |> Enum.map(fn point ->
    point
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1, 10))
    |> List.to_tuple()
  end)
end)
|> Stream.flat_map(fn
  [{x, a}, {x, b}] -> for y <- a..b, do: {x, y}
  [{a, y}, {b, y}] -> for x <- a..b, do: {x, y}
  _ -> []
end)
|> Enum.frequencies()
|> Enum.count(fn {_key, value} -> value > 1 end)
```

```output
5
```

## Second Star

Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture; you need to also consider diagonal lines.

Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

```
An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
```

Considering all lines from the above example would now produce the following diagram:

```
1.1....11.
.111...2..
..2.1.111.
...1.2.2..
.112313211
...1.2....
..1...1...
.1.....1..
1.......1.
222111....
```

You still need to determine the number of points where at least two lines overlap. In the above example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

Consider all of the lines. At how many points do at least two lines overlap?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> String.split("\n", trim: true)
|> Stream.map(fn line ->
  line
  |> String.split(" -> ", trim: true)
  |> Enum.map(fn point ->
    point
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1, 10))
    |> List.to_tuple()
  end)
end)
|> Stream.flat_map(fn
  [{x, a}, {x, b}] ->
    for y <- a..b, do: {x, y}

  [{a, y}, {b, y}] ->
    for x <- a..b, do: {x, y}

  [{a, b}, {c, d}] ->
    case div(c - a, d - b) do
      1 -> for x <- 0..(c - a), do: {a + x, b + x}
      -1 -> for x <- 0..(c - a), do: {a + x, b - x}
    end
end)
|> Enum.frequencies()
|> Enum.count(fn {_k, value} -> value > 1 end)
```

```output
12
```
