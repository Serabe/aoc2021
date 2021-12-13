# Day 13: Transparent Origami

## First Star

You reach another volcanically active part of the cave. It would be nice if you could do some kind of thermal imaging so you could tell ahead of time which caves are too hot to safely enter.

Fortunately, the submarine seems to be equipped with a thermal camera! When you activate it, you are greeted with:

Congratulations on your purchase! To activate this infrared thermal imaging
camera system, please enter the code found on page 1 of the manual.

Apparently, the Elves have never used this feature. To your surprise, you manage to find the manual; as you go to open it, page 1 falls out. It's a large sheet of transparent paper! The transparent paper is marked with random dots and includes instructions on how to fold it up (your puzzle input). For example:

```
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
```

The first section is a list of dots on the transparent paper. 0,0 represents the top-left coordinate. The first value, x, increases to the right. The second value, y, increases downward. So, the coordinate 3,0 is to the right of 0,0, and the coordinate 0,7 is below 0,0. The coordinates in this example form the following pattern, where # is a dot on the paper and . is an empty, unmarked position:

```
...#..#..#.
....#......
...........
#..........
...#....#.#
...........
...........
...........
...........
...........
.#....#.##.
....#......
......#...#
#..........
#.#........
```

Then, there is a list of fold instructions. Each instruction indicates a line on the transparent paper and wants you to fold the paper up (for horizontal y=... lines) or left (for vertical x=... lines). In this example, the first fold instruction is fold along y=7, which designates the line formed by all of the positions where y is 7 (marked here with -):

```
...#..#..#.
....#......
...........
#..........
...#....#.#
...........
...........
-----------
...........
...........
.#....#.##.
....#......
......#...#
#..........
#.#........
```

Because this is a horizontal line, fold the bottom half up. Some of the dots might end up overlapping after the fold is complete, but dots will never appear exactly on a fold line. The result of doing this fold looks like this:

```
#.##..#..#.
#...#......
......#...#
#...#......
.#.#..#.###
...........
...........
```

Now, only 17 dots are visible.

Notice, for example, the two dots in the bottom left corner before the transparent paper is folded; after the fold is complete, those dots appear in the top left corner (at 0,0 and 0,1). Because the paper is transparent, the dot just below them in the result (at 0,3) remains visible, as it can be seen through the transparent paper.

Also notice that some dots can end up overlapping; in this case, the dots merge together and become a single dot.

The second fold instruction is fold along x=5, which indicates this line:

```
#.##.|#..#.
#...#|.....
.....|#...#
#...#|.....
.#.#.|#.###
.....|.....
.....|.....
```

Because this is a vertical line, fold left:

```
#####
#...#
#...#
#...#
#####
.....
.....
```

The instructions made a square!

The transparent paper is pretty big, so for now, focus on just completing the first fold. After the first fold in the example above, 17 dots are visible - dots that end up overlapping after the fold is completed count as a single dot.

How many dots are visible after completing just the first fold instruction on your transparent paper?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"""
```

```output
"6,10\n0,14\n9,10\n0,3\n10,4\n4,11\n6,0\n6,12\n4,1\n0,13\n10,12\n3,4\n3,0\n8,4\n1,10\n2,14\n8,10\n9,0\n\nfold along y=7\nfold along x=5\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Parser do
  def build_square(square) do
    pairs =
      square
      |> String.splitter("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    size_x = pairs |> Stream.map(&elem(&1, 0)) |> Enum.max()
    size_y = pairs |> Stream.map(&elem(&1, 1)) |> Enum.max()

    {
      size_x + 1,
      size_y + 1,
      MapSet.new(pairs)
    }
  end

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> then(fn [square, instructions] ->
      {
        build_square(square),
        instructions
        |> String.splitter("\n", trim: true)
        |> Enum.map(fn
          "fold along x=" <> d -> {:x, String.to_integer(d)}
          "fold along y=" <> d -> {:y, String.to_integer(d)}
        end)
      }
    end)
  end
end

Parser.parse(input)
```

```output
{{11, 15,
  #MapSet<[
    {0, 3},
    {0, 13},
    {0, 14},
    {1, 10},
    {2, 14},
    {3, 0},
    {3, 4},
    {4, 1},
    {4, 11},
    {6, 0},
    {6, 10},
    {6, 12},
    {8, 4},
    {8, 10},
    {9, 0},
    {9, 10},
    {10, 4},
    {10, 12}
  ]>}, [y: 7, x: 5]}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Folder do
  def fold({_size_x, size_y, pairs}, {:x, n}) do
    {
      n,
      size_y,
      pairs
      |> Stream.map(fn
        {x, y} when x > n -> {2 * n - x, y}
        coord -> coord
      end)
      |> MapSet.new()
    }
  end

  def fold({size_x, _size_y, pairs}, {:y, n}) do
    {
      size_x,
      n,
      pairs
      |> Stream.map(fn
        {x, y} when y > n -> {x, 2 * n - y}
        coord -> coord
      end)
      |> MapSet.new()
    }
  end
end

input
|> Parser.parse()
|> then(fn {s, [f | _]} ->
  Folder.fold(s, f)
end)
|> then(fn {_, _, p} ->
  MapSet.size(p)
end)
```

```output
17
```

## Second Star

Finish folding the transparent paper according to the instructions. The manual says the code is always eight capital letters.

What code do you use to activate the infrared thermal imaging camera system?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Display do
  def display({size_x, size_y, pairs}) do
    Enum.each(0..(size_y - 1), fn y ->
      Enum.each(0..(size_x - 1), fn x ->
        case MapSet.member?(pairs, {x, y}) do
          true -> IO.write("#")
          false -> IO.write(".")
        end
      end)

      IO.puts("")
    end)
  end
end
```

```output
{:module, Display, <<70, 79, 82, 49, 0, 0, 8, ...>>, {:display, 1}}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> Parser.parse()
|> then(fn {s, instructions} ->
  instructions
  |> Enum.reduce(s, &Folder.fold(&2, &1))
end)
|> Display.display()
```

```output
#####
#...#
#...#
#...#
#####
.....
.....
```

```output
:ok
```
