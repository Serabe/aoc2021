# Day 12: Passage Pathing

## First Star

With your submarine's subterranean subsystems subsisting suboptimally, the only way you're getting out of this cave anytime soon is by finding a path yourself. Not just a path - the only way to know if you've found the best path is to find all of them.

Fortunately, the sensors are still mostly working, and so you build a rough map of the remaining caves (your puzzle input). For example:

```
start-A
start-b
A-c
A-b
b-d
A-end
b-end
```

This is a list of how all of the caves are connected. You start in the cave named start, and your destination is the cave named end. An entry like b-d means that cave b is connected to cave d - that is, you can move between them.

So, the above cave system looks roughly like this:

```
    start
    /   \
c--A-----b--d
    \   /
     end
```

Your goal is to find the number of distinct paths that start at start, end at end, and don't visit small caves more than once. There are two types of caves: big caves (written in uppercase, like A) and small caves (written in lowercase, like b). It would be a waste of time to visit any small cave more than once, but big caves are large enough that it might be worth visiting them multiple times. So, all paths you find should visit small caves at most once, and can visit big caves any number of times.

Given these rules, there are 10 paths through this example cave system:

```
start,A,b,A,c,A,end
start,A,b,A,end
start,A,b,end
start,A,c,A,b,A,end
start,A,c,A,b,end
start,A,c,A,end
start,A,end
start,b,A,c,A,end
start,b,A,end
start,b,end
```

(Each line in the above list corresponds to a single path; the caves visited by that path are listed in the order they are visited and separated by commas.)

Note that in this cave system, cave d is never visited by any path: to do so, cave b would need to be visited twice (once on the way to cave d and a second time when returning from cave d), and since cave b is small, this is not allowed.

Here is a slightly larger example:

```
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
```

The 19 paths through it are as follows:

```
start,HN,dc,HN,end
start,HN,dc,HN,kj,HN,end
start,HN,dc,end
start,HN,dc,kj,HN,end
start,HN,end
start,HN,kj,HN,dc,HN,end
start,HN,kj,HN,dc,end
start,HN,kj,HN,end
start,HN,kj,dc,HN,end
start,HN,kj,dc,end
start,dc,HN,end
start,dc,HN,kj,HN,end
start,dc,end
start,dc,kj,HN,end
start,kj,HN,dc,HN,end
start,kj,HN,dc,end
start,kj,HN,end
start,kj,dc,HN,end
start,kj,dc,end
```

Finally, this even larger example has 226 paths through it:

```
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
```

How many paths through this cave system are there that visit small caves at most once?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Parser do
  def parse(input) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.split(&1, "-"))
    |> Stream.flat_map(fn [a, b] -> [{a, b}, {b, a}] end)
    |> Enum.reduce(%{}, fn {a, b}, map ->
      Map.update(map, a, [b], fn v -> [b | v] end)
    end)
  end
end
```

```output
{:module, Parser, <<70, 79, 82, 49, 0, 0, 8, ...>>, {:parse, 1}}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule PathBuilder do
  defp can_visit_twice?(n), do: String.upcase(n) == n

  defp build_all_paths(map, unfinished_paths) do
    unfinished_paths
    |> Enum.flat_map(fn [h | t] ->
      map
      |> Map.get(h)
      |> Stream.map(fn n ->
        [n, h | t]
      end)
      |> Enum.filter(fn [h | t] ->
        case can_visit_twice?(h) do
          true ->
            true

          false ->
            !Enum.member?(t, h)
        end
      end)
    end)
  end

  defp build_recur(_map, [], paths), do: paths

  defp build_recur(map, unfinished_paths, finished_paths) do
    build_all_paths(map, unfinished_paths)
    |> Enum.group_by(fn [h | _] -> h == "start" end)
    |> then(fn grouped ->
      build_recur(
        map,
        Map.get(grouped, false, []),
        Map.get(grouped, true, []) ++ finished_paths
      )
    end)
  end

  def build(map) do
    build_recur(map, [["end"]], [])
  end
end
```

```output
{:module, PathBuilder, <<70, 79, 82, 49, 0, 0, 12, ...>>, {:build, 1}}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = """
start-A
start-b
A-c
A-b
b-d
A-end
b-end
"""
```

```output
"start-A\nstart-b\nA-c\nA-b\nb-d\nA-end\nb-end\n"
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> Parser.parse()
|> PathBuilder.build()
|> Enum.count()
```

```output
10
```

## Second Star

After reviewing the available paths, you realize you might have time to visit a single small cave twice. Specifically, big caves can be visited any number of times, a single small cave can be visited at most twice, and the remaining small caves can be visited at most once. However, the caves named start and end can only be visited exactly once each: once you leave the start cave, you may not return to it, and once you reach the end cave, the path must end immediately.

Now, the 36 possible paths through the first example above are:

```
start,A,b,A,b,A,c,A,end
start,A,b,A,b,A,end
start,A,b,A,b,end
start,A,b,A,c,A,b,A,end
start,A,b,A,c,A,b,end
start,A,b,A,c,A,c,A,end
start,A,b,A,c,A,end
start,A,b,A,end
start,A,b,d,b,A,c,A,end
start,A,b,d,b,A,end
start,A,b,d,b,end
start,A,b,end
start,A,c,A,b,A,b,A,end
start,A,c,A,b,A,b,end
start,A,c,A,b,A,c,A,end
start,A,c,A,b,A,end
start,A,c,A,b,d,b,A,end
start,A,c,A,b,d,b,end
start,A,c,A,b,end
start,A,c,A,c,A,b,A,end
start,A,c,A,c,A,b,end
start,A,c,A,c,A,end
start,A,c,A,end
start,A,end
start,b,A,b,A,c,A,end
start,b,A,b,A,end
start,b,A,b,end
start,b,A,c,A,b,A,end
start,b,A,c,A,b,end
start,b,A,c,A,c,A,end
start,b,A,c,A,end
start,b,A,end
start,b,d,b,A,c,A,end
start,b,d,b,A,end
start,b,d,b,end
start,b,end
```

The slightly larger example above now has 103 paths through it, and the even larger example now has 3509 paths through it.

Given these new rules, how many paths through this cave system are there?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule PathBuilder2 do
  defp can_visit_twice?(n), do: String.upcase(n) == n

  defp new_switch_value(_, "end"), do: nil

  defp new_switch_value({path, false}, n) do
    case can_visit_twice?(n) do
      true -> false
      false -> Enum.member?(path, n)
    end
  end

  defp new_switch_value({path, true}, n) do
    case can_visit_twice?(n) do
      true -> true
      false -> if Enum.member?(path, n), do: nil, else: true
    end
  end

  defp build_new_path(_, "end"), do: nil

  defp build_new_path({nodes, _} = path, n) do
    case new_switch_value(path, n) do
      nil -> nil
      v -> {[n | nodes], v}
    end
  end

  defp build_all_paths(map, unfinished_paths) do
    unfinished_paths
    |> Enum.flat_map(fn {[h | _tn], _} = path ->
      map
      |> Map.get(h)
      |> Stream.map(fn n ->
        build_new_path(path, n)
      end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  defp build_recur(_map, [], paths), do: paths

  defp build_recur(map, unfinished_paths, finished_paths) do
    build_all_paths(map, unfinished_paths)
    |> Enum.group_by(fn {[h | _], _} -> h == "start" end)
    |> then(fn grouped ->
      build_recur(
        map,
        Map.get(grouped, false, []),
        (Map.get(grouped, true, []) |> Enum.count()) + finished_paths
      )
    end)
  end

  def build(map) do
    build_recur(map, [{["end"], false}], 0)
  end
end
```

```output
{:module, PathBuilder2, <<70, 79, 82, 49, 0, 0, 14, ...>>, {:build, 1}}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input
|> Parser.parse()
|> PathBuilder2.build()
```

```output
36
```
