# Day 9: Smoke Basin

## First Star

These caves seem to be lava tubes. Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.

If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).

Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:

```
2199943210
3987894921
9856789892
8767896789
9899965678
```

Each number corresponds to the height of a particular location, where 9 is the highest and 0 is the lowest a location can be.

Your first goal is to find the low points - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)

In the above example, there are four low points, all highlighted: two are in the first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom row (also a 5). All other locations on the heightmap have some lower adjacent location, and so are not low points.

The risk level of a low point is 1 plus its height. In the above example, the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of all low points in the heightmap is therefore 15.

Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
2199943210
3987894921
9856789892
8767896789
9899965678
"""
```

```output
"2199943210\n3987894921\n9856789892\n8767896789\n9899965678\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
adjacent_coordinates = fn x, y, size_x, size_y ->
  [
    {x - 1, y},
    {x + 1, y},
    {x, y - 1},
    {x, y + 1}
  ]
  |> Enum.filter(fn {cx, cy} ->
    cx >= 0 && cx < size_x && cy >= 0 && cy < size_y
  end)
end

adjacent_coordinates.(2, 0, 10, 5)
```

```output
[{1, 0}, {3, 0}, {2, 1}]
```

First helper is straightforward.
From the list of possible adjacent
we filter those that are out of the board.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
get_value = fn {x, y}, hmap ->
  hmap
  |> elem(y)
  |> elem(x)
end
```

```output
#Function<43.40011524/2 in :erl_eval.expr/5>
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
{size_x, size_y, hmap} =
  state =
  input
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end)
  |> List.to_tuple()
  |> then(fn hmap ->
    {
      tuple_size(elem(hmap, 0)),
      tuple_size(hmap),
      hmap
    }
  end)

for(x <- 0..(size_x - 1), y <- 0..(size_y - 1), do: {x, y})
|> Enum.filter(fn {x, y} = coord ->
  value = get_value.(coord, hmap)

  adjacent_coordinates.(x, y, size_x, size_y)
  |> Enum.map(&get_value.(&1, hmap))
  |> Enum.all?(fn v -> v > value end)
end)
|> Enum.map(fn coord -> get_value.(coord, hmap) + 1 end)
|> Enum.sum()
```

```output
15
```

## Second Star

Next, you need to find the largest basins so you know what areas are most important to avoid.

A basin is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

The size of a basin is the number of locations within the basin, including the low point. The example above has four basins.

The top-left basin, size 3:

```
2199943210
3987894921
9856789892
8767896789
9899965678
```

The top-right basin, size 9:

```
2199943210
3987894921
9856789892
8767896789
9899965678
```

The middle basin, size 14:

```
2199943210
3987894921
9856789892
8767896789
9899965678
```

The bottom-right basin, size 9:

```
2199943210
3987894921
9856789892
8767896789
9899965678
```

Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

What do you get if you multiply together the sizes of the three largest basins?

```elixir
find_basin = fn
  [], basin, _, _recur ->
    basin

  [{x, y} = coord | t], basin, {size_x, size_y, hmap} = state, recur ->
    value = get_value.(coord, hmap)

    new_coords =
      adjacent_coordinates.(x, y, size_x, size_y)
      |> Enum.filter(fn coord ->
        v = get_value.(coord, hmap)
        v != 9 && v > value
      end)
      |> Enum.filter(fn coord -> !Enum.member?(basin, coord) end)
      |> Enum.filter(fn coord -> !Enum.member?(t, coord) end)

    recur.(new_coords ++ t, [coord | basin], state, recur)
end

find_basin.([{6, 4}], [], state, find_basin) |> Enum.count()
```

```output
9
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
for(x <- 0..(size_x - 1), y <- 0..(size_y - 1), do: {x, y})
|> Stream.filter(fn {x, y} = coord ->
  value = get_value.(coord, hmap)

  adjacent_coordinates.(x, y, size_x, size_y)
  |> Enum.map(&get_value.(&1, hmap))
  |> Enum.all?(fn v -> v > value end)
end)
|> Stream.map(fn coord ->
  find_basin.([coord], [], state, find_basin) |> Enum.count()
end)
|> Enum.reduce([], fn value, acc ->
  [value | acc]
  |> Enum.sort(:desc)
  |> Enum.take(3)
end)
|> Enum.reduce(fn a, b -> a * b end)
```

```output
1134
```
