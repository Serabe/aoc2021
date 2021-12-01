defmodule Aoc2021.Star01 do
  use Aoc2021.Day, read_as: :int

  def test_measurements() do
    [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
  end

  def number_of_increases(measurements \\ test_measurements()) do
    measurements
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
    |> Enum.filter(&(&1 > 0))
    |> Enum.count()
  end

  def number_of_increases_in_window(measurements \\ test_measurements()) do
    measurements
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> number_of_increases()
  end

  def run(), do: number_of_increases(read_input())

  def run2(), do: number_of_increases_in_window(read_input())
end
