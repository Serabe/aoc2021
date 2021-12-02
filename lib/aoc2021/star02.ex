defmodule Aoc2021.Star02 do
  use Aoc2021.Day

  defmodule FirstInterpreter do
    def apply_command("forward " <> h, {a, b}), do: {a + String.to_integer(h), b}
    def apply_command("down " <> d, {a, b}), do: {a, b + String.to_integer(d)}
    def apply_command("up " <> d, {a, b}), do: {a, b - String.to_integer(d)}
    def apply_command(_command, pos), do: pos
  end

  defmodule SecondInterpreter do
    def apply_command("down " <> c, {h, d, a}), do: {h, d, a + String.to_integer(c)}
    def apply_command("up " <> c, {h, d, a}), do: {h, d, a - String.to_integer(c)}

    def apply_command("forward " <> c, {h, d, a}) do
      units = String.to_integer(c)
      {h + units, d + units * a, a}
    end

    def apply_command(_command, pos), do: pos
  end

  def add2({a, b}, {c, d}), do: {a + c, b + d}

  def test_input do
    [
      "forward 5",
      "down 5",
      "forward 8",
      "up 3",
      "down 8",
      "forward 2"
    ]
  end

  def run(commands \\ read_input()) do
    {horizontal, depth} =
      commands
      |> Enum.reduce({0, 0}, &FirstInterpreter.apply_command(&1, &2))

    horizontal * depth
  end

  def run2(commands \\ read_input()) do
    {horizontal, depth, _aim} =
      commands |> Enum.reduce({0, 0, 0}, &SecondInterpreter.apply_command(&1, &2))

    horizontal * depth
  end
end
