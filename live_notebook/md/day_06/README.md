# Day 6: Lanternfish

## First Star

The sea floor is getting steeper. Maybe the sleigh keys got carried this way?

A massive school of glowing lanternfish swims past. They must spawn quickly to reach such large numbers - maybe exponentially quickly? You should model their growth rate to be sure.

Although you know nothing about this specific species of lanternfish, you make some guesses about their attributes. Surely, each lanternfish creates a new lanternfish once every 7 days.

However, this process isn't necessarily synchronized between every lanternfish - one lanternfish might have 2 days left until it creates another lanternfish, while another might have 4. So, you can model each fish as a single number that represents the number of days until it creates a new lanternfish.

Furthermore, you reason, a new lanternfish would surely need slightly longer before it's capable of producing more lanternfish: two more days for its first cycle.

So, suppose you have a lanternfish with an internal timer value of 3:

* After one day, its internal timer would become 2.
* After another day, its internal timer would become 1.
* After another day, its internal timer would become 0.
* After another day, its internal timer would reset to 6, and it would create a new lanternfish with an internal timer of 8.
* After another day, the first lanternfish would have an internal timer of 5, and the second lanternfish would have an internal timer of 7.

A lanternfish that creates a new fish resets its timer to 6, not 7 (because 0 is included as a valid timer value). The new lanternfish starts with an internal timer of 8 and does not start counting down until the next day.

Realizing what you're trying to do, the submarine automatically produces a list of the ages of several hundred nearby lanternfish (your puzzle input). For example, suppose you were given the following list:

```
3,4,3,1,2
```

This list means that the first fish has an internal timer of 3, the second fish has an internal timer of 4, and so on until the fifth fish, which has an internal timer of 2. Simulating these fish over several days would proceed as follows:

```
Initial state: 3,4,3,1,2
After  1 day:  2,3,2,0,1
After  2 days: 1,2,1,6,0,8
After  3 days: 0,1,0,5,6,7,8
After  4 days: 6,0,6,4,5,6,7,8,8
After  5 days: 5,6,5,3,4,5,6,7,7,8
After  6 days: 4,5,4,2,3,4,5,6,6,7
After  7 days: 3,4,3,1,2,3,4,5,5,6
After  8 days: 2,3,2,0,1,2,3,4,4,5
After  9 days: 1,2,1,6,0,1,2,3,3,4,8
After 10 days: 0,1,0,5,6,0,1,2,2,3,7,8
After 11 days: 6,0,6,4,5,6,0,1,1,2,6,7,8,8,8
After 12 days: 5,6,5,3,4,5,6,0,0,1,5,6,7,7,7,8,8
After 13 days: 4,5,4,2,3,4,5,6,6,0,4,5,6,6,6,7,7,8,8
After 14 days: 3,4,3,1,2,3,4,5,5,6,3,4,5,5,5,6,6,7,7,8
After 15 days: 2,3,2,0,1,2,3,4,4,5,2,3,4,4,4,5,5,6,6,7
After 16 days: 1,2,1,6,0,1,2,3,3,4,1,2,3,3,3,4,4,5,5,6,8
After 17 days: 0,1,0,5,6,0,1,2,2,3,0,1,2,2,2,3,3,4,4,5,7,8
After 18 days: 6,0,6,4,5,6,0,1,1,2,6,0,1,1,1,2,2,3,3,4,6,7,8,8,8,8
```

Each day, a 0 becomes a 6 and adds a new 8 to the end of the list, while each other number decreases by 1 if it was present at the start of the day.

In this example, after 18 days, there are a total of 26 fish. After 80 days, there would be a total of 5934.

Find a way to simulate lanternfish. How many lanternfish would there be after 80 days?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
3,4,3,1,2
"""
```

```output
"3,4,3,1,2\n"
```

Parsing in this case is soooooo simple. We just need to `String.trim\1`, `String.split\3` and parse each number.

Given each input is repeated several times, we will build a cache.
That way, we just need to compute `3` once, `2` once, etc.
Then, with that cache, we can just `pond |> Stream.map(&elem(cache, &1)) |> Enum.sum()`

In this first exercise, the cache can be built directly, we'll try a different
approach later.

Each lanternfish will be represented as `{countdown, number_of_days}` tuple.

Our `compute\3` function will have 4 branches:

1. If the list is empty, we just return the total.
2. If the first element matches `{c, 0}`, we will recur with the rest of the pond
   and `total + 1`. We are counting the fishes as we take them out of the pond.
3. If the first element matches `{0, n}`, we will recur our function with
    the same fish resetted, a new fish and the rest of the pond. Same total.
4. In any other case, recur with the same pond but substracting one to each component
   of the head lanternfish.

The last recursion can be changed from `{n, m}` to `{n - 1, m - 1}` to `{0, max(0, m - n)}`.

This approach is fast enough for this first star.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
number_of_days = 80
new_born_countdown = 8
restart_countdown = 6

compute = fn
  _recur, [], total ->
    total

  recur, [{_countdown, 0} | t], total ->
    recur.(recur, t, total + 1)

  recur, [{0, nod} | t], total ->
    recur.(
      recur,
      [{restart_countdown, nod - 1}, {new_born_countdown, nod - 1} | t],
      total
    )

  recur, [{n, nod} | t], total ->
    recur.(
      recur,
      [{0, max(0, nod - n)} | t],
      total
    )
end

pond =
  input
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

max = pond |> Enum.max()

precompute =
  0..max |> Enum.map(fn n -> compute.(compute, [{n, number_of_days}], 0) end) |> List.to_tuple()

pond |> Stream.map(fn n -> elem(precompute, n) end) |> Enum.sum()
```

```output
5934
```

## Second Star

Suppose the lanternfish live forever and have unlimited food and space. Would they take over the entire ocean?

After 256 days in the example above, there would be a total of 26984457539 lanternfish!

<!-- livebook:{"break_markdown":true} -->

In this case, our previous code is way toooooooo slow.
We will create a new version of `compute` that gets another arguments that is a map from tuples
`{0, number_of_days}` to total number of lanternfishes.

Besides adding a new argument and passing it along in recursion, we need to modify
the third branch.

This branch will look the cache for the element and, if it is found, remove the lanternfish
and recur adding the value found in the cache to the total.

Then we need to build the cache. To do so, we'll start creating it from `0` up to `256`.
We will use reduce so we can reuse the cache from previous steps in the new one.

Then, we just apply the same logic as in the first star: we precompute values, then map the input
and add it up.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
compute_with_cache = fn
  _recur, [], total, _cache ->
    total

  recur, [{_countdown, 0} | t], total, cache ->
    recur.(recur, t, total + 1, cache)

  recur, [{0, nod} | t], total, cache ->
    case Map.get(cache, {0, nod}) do
      nil ->
        recur.(
          recur,
          [{restart_countdown, nod - 1}, {new_born_countdown, nod - 1} | t],
          total,
          cache
        )

      n ->
        recur.(
          recur,
          t,
          total + n,
          cache
        )
    end

  recur, [{n, nod} | t], total, cache ->
    recur.(
      recur,
      [{0, max(0, nod - n)} | t],
      total,
      cache
    )
end

first_cache =
  0..256
  |> Enum.reduce(%{}, fn n, map ->
    Map.put(map, {0, n}, compute_with_cache.(compute_with_cache, [{0, n}], 0, map))
  end)

cache =
  0..Enum.max(pond)
  |> Enum.map(fn n ->
    compute_with_cache.(compute_with_cache, [{n, 256}], 0, first_cache)
  end)
  |> List.to_tuple()

pond |> Enum.map(&elem(cache, &1)) |> Enum.sum()
```

```output
26984457539
```
