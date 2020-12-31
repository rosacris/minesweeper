defmodule Minesweeper.Board do
  @moduledoc "Minesweeper board logic implementation"

  alias Minesweeper.Board.Cell

  @type board :: %{rows: non_neg_integer(), cols: non_neg_integer(), cells: list(Cell.t())}

  #
  # Macros
  #

  defguardp is_in_board(board, row, col)
            when is_map(board) and
                 row >= 0 and
                 col >= 0 and
                 row < :erlang.map_get(:rows, board) and
                 col < :erlang.map_get(:cols, board)

  #
  # Public API
  #

  @doc """
  Returns a new board of `rows` * `cols` size with the given `mines_amount`

  It takes an optional `seed` parameter that forces the randomizer seed useful to make
  the board generation deterministic (i.e. for testing).
  """
  @spec new(non_neg_integer(), non_neg_integer(), non_neg_integer(), any()) :: board()
  def new(rows, cols, mines_amount, seed \\ nil) do
    # Seed the random number generator if given to recreate the same board.
    if seed, do: :rand.seed(:exrop, seed)

    # Generate payloads to be assigned to each cell
    mine_payloads = for _ <- 0..(mines_amount - 1), do: :mine
    nomine_payloads = for _ <- 0..(rows * cols - mines_amount - 1), do: :no_mine
    payloads = Enum.shuffle(mine_payloads ++ nomine_payloads)

    # Generate cells and assign a payload to each
    cells =
      for(i <- 0..(rows - 1), j <- 0..(cols - 1), do: {i, j})
      |> Enum.zip(payloads)
      |> Enum.map(fn {{row, col}, payload} -> Cell.new(row, col, payload, :unexplored) end)

    %{rows: rows, cols: cols, cells: cells}
  end

  @doc "Returns the cell at `row` `col`"
  @spec get_cell(board(), non_neg_integer(), non_neg_integer()) :: Cell.t()
  def get_cell(board, row, col) when is_in_board(board, row, col),
    do: Enum.at(board.cells, row * board.cols + col)

  def swipe(), do: raise("Unimplemented")

  @doc "Marks the cell as possible mine"
  @spec mark(board(), non_neg_integer(), non_neg_integer()) :: board()
  def mark(board, row, col) when is_in_board(board, row, col) do
    updated_cells =
      Enum.map(board.cells, fn
        {^row, ^col, _, _} = cell -> Cell.mark(cell)
        cell -> cell
      end)

    %{board | cells: updated_cells}
  end

  def flag(), do: raise("Unimplemented")

  def decide(), do: raise("Unimplemented")

  #
  # Private functions
  #


end
