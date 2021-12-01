defmodule Aoc2021.Day do
  @doc false
  defmacro __using__(opts) do
    type_to_read = Keyword.get(opts, :read_as, :string)

    quote do
      import Aoc2021.Day

      def aoc_file_name() do
        __MODULE__
        |> to_string()
        |> String.split(".", trim: true)
        |> Enum.at(-1)
        |> String.downcase()
      end

      def convert(input) do
        case unquote(type_to_read) do
          :string -> input
          :int -> as_int(input)
        end
      end

      def read_input() do
        aoc_file_name()
        |> read_input()
        |> convert()
      end
    end
  end

  def read_input(name) do
    Path.join([__ENV__.file, "..", "..", "inputs", "#{name}.txt"])
    |> Path.expand()
    |> File.read!()
    |> String.split("\n")
  end

  def as_int(list) do
    list
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(fn {int, _} -> int end)
  end
end
