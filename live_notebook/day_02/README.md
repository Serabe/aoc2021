# Day 2: Dive!

## First Star

Now, you need to figure out how to pilot this thing.

It seems like the submarine can take a series of commands like forward 1, down 2, or up 3:

* forward X increases the horizontal position by X units.
* down X increases the depth by X units.
* up X decreases the depth by X units.

Note that since you're on a submarine, down and up affect your depth, and so they have the opposite result of what you might expect.

The submarine seems to already have a planned course (your puzzle input). You should probably figure out where it's going. For example:

```
forward 5
down 5
forward 8
up 3
down 8
forward 2
```

Your horizontal position and depth both start at 0. The steps above would then modify them as follows:

* forward 5 adds 5 to your horizontal position, a total of 5.
* down 5 adds 5 to your depth, resulting in a value of 5.
* forward 8 adds 8 to your horizontal position, a total of 13.
* up 3 decreases your depth by 3, resulting in a value of 2.
* down 8 adds 8 to your depth, resulting in a value of 10.
* forward 2 adds 2 to your horizontal position, a total of 15.

After following these instructions, you would have a horizontal position of 15 and a depth of 10. (Multiplying these together produces 150.)

Calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
input = [
  "forward 5",
  "down 5",
  "forward 8",
  "up 3",
  "down 8",
  "forward 2"
]
```

```output
["forward 5", "down 5", "forward 8", "up 3", "down 8", "forward 2"]
```

Our solution will be based on an interpreter. That main method will take each command and a position. The method will return the new position. In this first part, it will be a 2-tuple `{horizontal_position, depth}`

<!-- livebook:{"break_markdown":true} -->

We will also use pattern matching on the commands. We can partially match a string as we see in our interpreter:

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule FirstInterpreter do
  def apply_command("forward " <> c, {a, b}), do: {a + String.to_integer(c), b}
  def apply_command("down " <> c, {a, b}), do: {a, b + String.to_integer(c)}
  def apply_command("up " <> c, {a, b}), do: {a, b - String.to_integer(c)}
  def apply_command(_command, pos), do: pos
end
```

```output
{:module, FirstInterpreter, <<70, 79, 82, 49, 0, 0, 7, ...>>, {:apply_command, 2}}
```

See how we are matching the command `"forward 8"` with `"forward " <> c`, and Elixir is setting `c` to `"8"` automatically. We match all known commands and then, just in case, we get a catch-all clause that just return the same position.

<!-- livebook:{"break_markdown":true} -->

For finding the last position, we just reduce the function like this:

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
{h1, d1} = Enum.reduce(input, {0, 0}, &FirstInterpreter.apply_command/2)
```

```output
{15, 10}
```

The solution is `h1 * d1`

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
h1 * d1
```

```output
150
```

## Second Star

Based on your calculations, the planned course doesn't seem to make any sense. You find the submarine manual and discover that the process is actually slightly more complicated.

In addition to horizontal position and depth, you'll also need to track a third value, aim, which also starts at 0. The commands also mean something entirely different than you first thought:

* down X increases your aim by X units.
* up X decreases your aim by X units.
* forward X does two things:
  * It increases your horizontal position by X units.
  * It increases your depth by your aim multiplied by X.

Again note that since you're on a submarine, down and up do the opposite of what you might expect: "down" means aiming in the positive direction.

Now, the above example does something different:

* forward 5 adds 5 to your horizontal position, a total of 5. Because your aim is 0, your depth does not change.
* down 5 adds 5 to your aim, resulting in a value of 5.
* forward 8 adds 8 to your horizontal position, a total of 13. Because your aim is 5, your depth increases by 8*5=40.
* up 3 decreases your aim by 3, resulting in a value of 2.
* down 8 adds 8 to your aim, resulting in a value of 10.
* forward 2 adds 2 to your horizontal position, a total of 15. Because your aim is 10, your depth increases by 2*10=20 to a total of 60.

After following these new instructions, you would have a horizontal position of 15 and a depth of 60. (Multiplying these produces 900.)

Using this new interpretation of the commands, calculate the horizontal position and depth you would have after following the planned course. What do you get if you multiply your final horizontal position by your final depth?

<!-- livebook:{"break_markdown":true} -->

We need to write a new interpreter! In this case, our tuple will contain three elements `{horizontal_position, depth, aim}`. For the rest, pretty straightforward too!

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule SecondInterpreter do
  def apply_command("down " <> c, {h, d, a}), do: {h, d, a + String.to_integer(c)}
  def apply_command("up " <> c, {h, d, a}), do: {h, d, a - String.to_integer(c)}

  def apply_command("forward " <> c, {h, d, a}) do
    units = String.to_integer(c)
    {h + units, d + units * a, a}
  end

  def apply_command(_command, pos), do: pos
end
```

```output
{:module, SecondInterpreter, <<70, 79, 82, 49, 0, 0, 7, ...>>, {:apply_command, 2}}
```

Using the interpreter is pretty close to the first star too:

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
{h2, d2, _aim} = Enum.reduce(input, {0, 0, 0}, &SecondInterpreter.apply_command/2)
```

```output
{15, 60, 10}
```

And the final result is `h2 * d2`

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
h2 * d2
```

```output
900
```
