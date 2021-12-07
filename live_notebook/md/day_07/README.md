# Day 07: The Treachery of Whales

## First Star

A giant whale has decided your submarine is its next meal, and it's much faster than you are. There's nowhere to run!

Suddenly, a swarm of crabs (each in its own tiny submarine - it's too deep for them otherwise) zooms in to rescue you! They seem to be preparing to blast a hole in the ocean floor; sensors indicate a massive underground cave system just beyond where they're aiming!

The crab submarines all need to be aligned before they'll have enough power to blast a large enough hole for your submarine to get through. However, it doesn't look like they'll be aligned before the whale catches you! Maybe you can help?

There's one major catch - crab submarines can only move horizontally.

You quickly make a list of the horizontal position of each crab (your puzzle input). Crab submarines have limited fuel, so you need to find a way to make all of their horizontal positions match while requiring them to spend as little fuel as possible.

For example, consider the following horizontal positions:

```
16,1,2,0,4,2,7,1,2,14
```

This means there's a crab with horizontal position 16, a crab with horizontal position 1, and so on.

Each change of 1 step in horizontal position of a single crab costs 1 fuel. You could choose any horizontal position to align them all on, but the one that costs the least fuel is horizontal position 2:

* Move from 16 to 2: 14 fuel
* Move from 1 to 2: 1 fuel
* Move from 2 to 2: 0 fuel
* Move from 0 to 2: 2 fuel
* Move from 4 to 2: 2 fuel
* Move from 2 to 2: 0 fuel
* Move from 7 to 2: 5 fuel
* Move from 1 to 2: 1 fuel
* Move from 2 to 2: 0 fuel
* Move from 14 to 2: 12 fuel

This costs a total of 37 fuel. This is the cheapest possible outcome; more expensive outcomes include aligning at position 1 (41 fuel), position 3 (39 fuel), or position 10 (71 fuel).

Determine the horizontal position that the crabs can align to using the least fuel possible. How much fuel must they spend to align to that position?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
16,1,2,0,4,2,7,1,2,14
"""
```

```output
"16,1,2,0,4,2,7,1,2,14\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
crab_submarines =
  input
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer(&1, 10))
```

```output
[16, 1, 2, 0, 4, 2, 7, 1, 2, 14]
```

We will select a pivot and start moving from there.

With the pivot `p`, we will split the crab submarines in three subsets:

1. A: Crab submarines at the left of `p` (`c < p`)
2. B: Crab submarines exactly at `p`.
3. C: Crab submarines at the right of `p` (`c > p`)

If `abs(|A| - |C|) < |B|` we've reached the optimum, as moving either way would add more fuel.
Otherwise, we will be moving in one direction or another.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
pivot = div(Enum.max(crab_submarines), 2)
IO.inspect("Initial pivot: #{pivot}")

compute = fn recur, {{smaller, equal, greater}, pivot, fuel} ->
  IO.inspect("Pivot: #{pivot}, fuel: #{fuel}")
  s = length(smaller)
  e = length(equal)
  g = length(greater)

  cond do
    g - s > e ->
      recur.(
        recur,
        {
          {
            smaller ++ equal,
            greater |> Enum.filter(fn n -> n == pivot + 1 end),
            greater |> Enum.filter(fn n -> n > pivot + 1 end)
          },
          pivot + 1,
          fuel + length(smaller) + length(equal) - length(greater)
        }
      )

    s - g > e ->
      recur.(
        recur,
        {
          {
            smaller |> Enum.filter(fn n -> n < pivot - 1 end),
            smaller |> Enum.filter(fn n -> n == pivot - 1 end),
            equal ++ greater
          },
          pivot - 1,
          fuel - length(smaller) + length(equal) + length(greater)
        }
      )

    true ->
      fuel
  end
end

create_initial_state = fn fleet ->
  pivot = div(Enum.max(fleet), 2)

  fleet
  |> Enum.group_by(fn n ->
    cond do
      n < pivot -> :smaller
      n == pivot -> :equal
      n > pivot -> :greater
    end
  end)
  |> then(fn map ->
    {
      Map.get(map, :smaller, []),
      Map.get(map, :equal, []),
      Map.get(map, :greater, [])
    }
  end)
  |> then(fn {smaller, _equal, greater} = partition ->
    {
      partition,
      pivot,
      pivot * length(smaller) - Enum.sum(smaller) + Enum.sum(greater) - pivot * length(greater)
    }
  end)
end

crab_submarines
|> create_initial_state.()
|> then(fn state -> compute.(compute, state) end)
```

```output
"Initial pivot: 8"
"Pivot: 8, fuel: 59"
"Pivot: 7, fuel: 53"
"Pivot: 6, fuel: 49"
"Pivot: 5, fuel: 45"
"Pivot: 4, fuel: 41"
"Pivot: 3, fuel: 39"
"Pivot: 2, fuel: 37"
```

```output
37
```

## Second Star

The crabs don't seem interested in your proposed solution. Perhaps you misunderstand crab engineering?

As it turns out, crab submarine engines don't burn fuel at a constant rate. Instead, each change of 1 step in horizontal position costs 1 more unit of fuel than the last: the first step costs 1, the second step costs 2, the third step costs 3, and so on.

As each crab moves, moving further becomes more expensive. This changes the best horizontal position to align them all on; in the example above, this becomes 5:

* Move from 16 to 5: 66 fuel
* Move from 1 to 5: 10 fuel
* Move from 2 to 5: 6 fuel
* Move from 0 to 5: 15 fuel
* Move from 4 to 5: 1 fuel
* Move from 2 to 5: 6 fuel
* Move from 7 to 5: 3 fuel
* Move from 1 to 5: 10 fuel
* Move from 2 to 5: 6 fuel
* Move from 14 to 5: 45 fuel

This costs a total of 168 fuel. This is the new cheapest possible outcome; the old alignment position (2) now costs 206 fuel instead.

Determine the horizontal position that the crabs can align to using the least fuel possible so they can make you an escape route! How much fuel must they spend to align to that position?

<!-- livebook:{"break_markdown":true} -->

In this case, working out the direction we need to go is a bit harder.
We will be using a few helpers for working out the fuel of one crab submarine and the fleet.
Likewise, we have helpers to check the difference in fuel between two points.

```elixir
fuel = fn from, to ->
  div(abs(from - to) * (abs(from - to) + 1), 2)
end

diff_fuel = fn from, to1, to2 -> fuel.(from, to2) - fuel.(from, to1) end

fleet_fuel = fn fleet, pivot ->
  fleet
  |> Stream.map(fn n -> fuel.(n, pivot) end)
  |> Enum.sum()
end

fleet_diff_fuel = fn fleet, to1, to2 ->
  fleet
  |> Stream.map(fn n -> diff_fuel.(n, to1, to2) end)
  |> Enum.sum()
end
```

```output
#Function<42.40011524/3 in :erl_eval.expr/5>
```

In the same way, the conditions to choose the branch is a bit different, but follows the same logic.
If it is cheaper to go one direction it'll be more expensive to go in the opposite direction.
Adjusting fuel is similar.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
compute2 = fn recur, {{smaller, equal, greater}, pivot, fuel} ->
  IO.inspect("Pivot: #{pivot}, fuel: #{fuel}")

  cond do
    fleet_diff_fuel.(greater, pivot, pivot + 1) + fleet_diff_fuel.(smaller, pivot, pivot + 1) +
      length(equal) <= 0 ->
      recur.(
        recur,
        {
          {
            smaller ++ equal,
            greater |> Enum.filter(fn n -> n == pivot + 1 end),
            greater |> Enum.filter(fn n -> n > pivot + 1 end)
          },
          pivot + 1,
          fuel + fleet_diff_fuel.(smaller, pivot, pivot + 1) + length(equal) +
            fleet_diff_fuel.(greater, pivot, pivot + 1)
        }
      )

    fleet_diff_fuel.(greater, pivot, pivot - 1) + fleet_diff_fuel.(smaller, pivot, pivot - 1) +
      length(equal) <= 0 ->
      recur.(
        recur,
        {
          {
            smaller |> Enum.filter(fn n -> n < pivot - 1 end),
            smaller |> Enum.filter(fn n -> n == pivot - 1 end),
            equal ++ greater
          },
          pivot - 1,
          fuel + fleet_diff_fuel.(smaller, pivot, pivot - 1) + length(equal) +
            fleet_diff_fuel.(greater, pivot, pivot - 1)
        }
      )

    true ->
      fuel
  end
end
```

```output
#Function<43.40011524/2 in :erl_eval.expr/5>
```

While we will be using the same function from the first star, we need to adjust the initial fuel.

```elixir
adjust_fuel = fn {{smaller, equal, greater}, pivot, _f} ->
  {{smaller, equal, greater}, pivot, fleet_fuel.(smaller, pivot) + fleet_fuel.(greater, pivot)}
end

crab_submarines
|> create_initial_state.()
|> adjust_fuel.()
|> then(fn state -> compute2.(compute2, state) end)
```

```output
"Pivot: 8, fuel: 223"
"Pivot: 7, fuel: 194"
"Pivot: 6, fuel: 176"
"Pivot: 5, fuel: 168"
```

```output
168
```
