defmodule Aoc2021.Day03 do
  use Aoc2021.Day

  defmodule Freq do
    defstruct zero: 0, one: 0

    def add_freq("0", %Freq{zero: zero} = freq), do: %Freq{freq | zero: zero + 1}
    def add_freq("1", %Freq{one: one} = freq), do: %Freq{freq | one: one + 1}
    def add_freq(_, freq), do: freq

    def common(%Freq{zero: zero, one: one}) when zero > one, do: "0"
    def common(%Freq{}), do: "1"

    def uncommon(%Freq{zero: zero, one: one}) when zero <= one, do: "0"
    def uncommon(%Freq{}), do: "1"
  end

  def test_input() do
    [
      "00100",
      "11110",
      "10110",
      "10111",
      "10101",
      "01111",
      "00111",
      "11100",
      "10000",
      "11001",
      "00010",
      "01010"
    ]
  end

  def as_bin_number(list), do: list |> Enum.join() |> String.to_integer(2)

  def init_freqs(first) do
    1..String.length(first) |> Enum.map(fn _ -> %Freq{} end)
  end

  def update_freqs(freqs, input) do
    input
    |> String.split("", trim: true)
    |> Enum.zip(freqs)
    |> Enum.map(fn {d, freq} -> Freq.add_freq(d, freq) end)
  end

  def run(input \\ test_input()) do
    case input do
      [h | _t] -> run1(input, init_freqs(h))
      _ -> 0
    end
  end

  defp run1([], freqs) do
    gamma_rate = freqs |> Enum.map(&Freq.common/1) |> as_bin_number()
    epsilon_rate = freqs |> Enum.map(&Freq.uncommon/1) |> as_bin_number()

    gamma_rate * epsilon_rate
  end

  defp run1([h | t], freqs) do
    run1(t, update_freqs(freqs, h))
  end

  def run2(input \\ test_input()) do
    splitted_input = split_input(input)
    oxygen_generator_rating = find_complex_rating(splitted_input, &Freq.common/1, 0)
    co2_scrubber_rating = find_complex_rating(splitted_input, &Freq.uncommon/1, 0)

    oxygen_generator_rating * co2_scrubber_rating
  end

  def find_complex_rating([el], _criteria, _bit_pos),
    do: el |> Enum.join() |> String.to_integer(2)

  def find_complex_rating(input, criteria, bit_pos) do
    freq = freqs_on_bit(input, bit_pos)
    bit_to_match = criteria.(freq)

    find_complex_rating(
      Enum.filter(input, fn el -> Enum.at(el, bit_pos) == bit_to_match end),
      criteria,
      bit_pos + 1
    )
  end

  defp split_input(input) do
    input |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp freqs_on_bit(input, bit_pos) do
    input
    |> Stream.map(&Enum.at(&1, bit_pos))
    |> Enum.reduce(%Freq{}, fn bit, freq -> Freq.add_freq(bit, freq) end)
  end
end
