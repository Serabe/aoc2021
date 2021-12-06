# Day 4: Giant Squid

## First Star

You're already almost 1.5km (almost a mile) below the surface of the ocean, already so deep that you can't see any sunlight. What you can see, however, is a giant squid that has attached itself to the outside of your submarine.

Maybe it wants to play bingo?

Bingo is played on a set of boards each consisting of a 5x5 grid of numbers. Numbers are chosen at random, and the chosen number is marked on all boards on which it appears. (Numbers may not appear on all boards.) If all numbers in any row or any column of a board are marked, that board wins. (Diagonals don't count.)

The submarine has a bingo subsystem to help passengers (currently, you and the giant squid) pass the time. It automatically generates a random order in which to draw numbers and a random set of boards (your puzzle input). For example:

```
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
```

After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no winners, but the boards are marked as follows (shown here adjacent to each other to save space):

```
22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
```

After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are still no winners:

```
22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
```

Finally, 24 is drawn:

```
22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
 8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
 6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
 1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
```

At this point, the third board wins because it has at least one complete row or column of marked numbers (in this case, the entire top row is marked: 14 21 17 24 4).

The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won, 24, to get the final score, 188 * 24 = 4512.

To guarantee victory against the giant squid, figure out which board will win first. What will your final score be if you choose that board?

```elixir
input = """
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"""
```

```output
"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1\n\n22 13 17 11  0\n 8  2 23  4 24\n21  9 14 16  7\n 6 10  3 18  5\n 1 12 20 15 19\n\n 3 15  0  2 22\n 9 18 13 17  5\n19  8  7 25 23\n20 11 10 24  4\n14 21 16 12  6\n\n14 21 17 24  4\n10 16 15  9 19\n18  8 23 26 20\n22 11 13  6  5\n 2  0 12  3  7\n"
```

We will be transposing matrixes, so a quick function to do so will be appreaciated:

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
transpose = fn matrix -> matrix |> Enum.zip() |> Enum.map(&Tuple.to_list/1) end
```

```output
#Function<44.40011524/1 in :erl_eval.expr/5>
```

First, we need to parse both the draw order and each board.
We will create a board struct to hold all the info.
The Board will contain both the rows and columns.
Each cell will contain a tuple with the number and whether it is marked or not.

We'll need some functions to check if the board has won and, if so, the score only in the board.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
defmodule Board do
  defstruct rows: [], columns: []

  def transpose(matrix), do: matrix |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

  def new(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(fn value -> {String.to_integer(value, 10), false} end)
    end)
    |> then(fn rows ->
      %__MODULE__{
        rows: rows,
        columns: transpose(rows)
      }
    end)
  end

  def won?(%__MODULE__{rows: rows, columns: columns}) do
    Stream.concat(rows, columns)
    |> Enum.any?(fn numbers -> Enum.all?(numbers, fn {_, marked} -> marked end) end)
  end

  def mark(board, number) do
    %__MODULE__{
      rows: board.rows |> Enum.map(fn row -> row |> Enum.map(&mark_number(&1, number)) end),
      columns:
        board.columns |> Enum.map(fn column -> column |> Enum.map(&mark_number(&1, number)) end)
    }
  end

  def mark_number({number, false}, number), do: {number, true}
  def mark_number(cell, _), do: cell

  def score(%__MODULE__{rows: rows}, number \\ 1) do
    number *
      (rows
       |> Enum.concat()
       |> Enum.reduce(0, fn
         {number, false}, acc -> acc + number
         _, acc -> acc
       end))
  end
end
```

```output
{:module, Board, <<70, 79, 82, 49, 0, 0, 20, ...>>, {:score, 2}}
```

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
# New board
board =
  Board.new("""
  22 13 17 11  0
   8  2 23  4 24
  21  9 14 16  7
   6 10  3 18  5
   1 12 20 15 19
  """)

# It has not won yet
IO.puts(Board.won?(board))

board
|> Board.mark(22)
|> Board.mark(8)
|> Board.mark(21)
|> Board.mark(6)
|> Board.mark(1)
|> Board.won?()

# It won!
```

```output
false
```

```output
true
```

Let's parse the input!

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
[draw_order | boards] =
  input
  |> String.split("\n\n", trim: true)
  |> then(fn [draw | boards] ->
    [
      draw |> String.split(",", trim: true) |> Enum.map(&String.to_integer(&1, 10))
      | Enum.map(boards, &Board.new/1)
    ]
  end)

length(boards)
```

```output
3
```

Finally, we will write a function that will consume one input at a time and check if any board has won.

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
run1 = fn
  recur, [next_ball | t], boards ->
    new_boards = Enum.map(boards, &Board.mark(&1, next_ball))

    case Enum.find(new_boards, &Board.won?/1) do
      nil -> recur.(recur, t, new_boards)
      board -> Board.score(board, next_ball)
    end

  _recur, [], _boards ->
    raise "Something went really wrong :("
end

run1.(run1, draw_order, boards)
```

```output
4512
```

## Second star

On the other hand, it might be wise to try a different strategy: let the giant squid win.

You aren't sure how many bingo boards a giant squid could play at once, so rather than waste time counting its arms, the safe thing to do is to figure out which board will win last and choose that one. That way, no matter which boards it picks, it will win for sure.

In the above example, the second board is the last to win, which happens after 13 is eventually called and its middle column is completely marked. If you were to keep playing until this point, the second board would have a sum of unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.

Figure out which board will win last. Once it wins, what would its final score be?

<!-- livebook:{"break_markdown":true} -->

We will need to keep track of the last board that has won and check for a few other corner cases, but this is now pretty simple too!

<!-- livebook:{"reevaluate_automatically":true} -->

```elixir
run2 = fn
  _recur, [], _boards, last_board_score ->
    last_board_score

  _recur, _draw_order, [], last_board_score ->
    last_board_score

  recur, [next_ball | t], boards, last_board_score ->
    new_boards = Enum.map(boards, &Board.mark(&1, next_ball))

    case Enum.find(new_boards, &Board.won?/1) do
      nil ->
        recur.(recur, t, new_boards, last_board_score)

      board ->
        recur.(
          recur,
          t,
          Enum.filter(new_boards, fn b -> !Board.won?(b) end),
          Board.score(board, next_ball)
        )
    end
end

run2.(run2, draw_order, boards, -1)
```

```output
1924
```

In this case, each time we find a new board that wins in that turn, we recur with:

1. The same recurring function.
2. The next numbers to be drawn.
3. All the boards that has not won.
4. The new last score.
