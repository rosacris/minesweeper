defmodule Minesweeper.Board do
  @moduledoc "Minesweeper board logic implementation"

  alias Minesweeper.Board.Cell

  @type board :: %{rows: non_neg_integer(), cols: non_neg_integer(), cells: list(Cell.t())}

  #
  # Macros
  #

  # Checks that the given row and col reside inside the board dimensions
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

  def get_cell(_, _, _), do: raise("Invalid cell")

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

  def mark(_, _, _), do: raise("Invalid cell")

  @doc "Flag the cell as a mine"
  @spec flag(board(), non_neg_integer(), non_neg_integer()) :: board()
  def flag(board, row, col) when is_in_board(board, row, col) do
    updated_cells =
      Enum.map(board.cells, fn
        {^row, ^col, _, _} = cell -> Cell.flag(cell)
        cell -> cell
      end)

    %{board | cells: updated_cells}
  end

  def flag(_, _, _), do: raise("Invalid cell")

  @doc "Swipes a board cell"
  @spec swipe(board(), non_neg_integer(), non_neg_integer()) :: board()
  def swipe(board, row, col) when is_in_board(board, row, col) do
    cell = get_cell(board, row, col)

    swiped_cells =
      if Cell.cleared?(cell) or Cell.flagged?(cell) do
        []
      else
        if Cell.mine?(cell) do
          [Cell.swipe(cell)]
        else
          do_swipe(board, [cell], [], [])
        end
      end

    %{board | cells: update_cells(board.cells, swiped_cells)}
  end

  def swipe(_, _, _), do: raise("Invalid cell")

  def decide(), do: raise("Unimplemented")

  #
  # Private functions
  #

  # Runs recursively the swipe algorithm until there are no more cells to explore
  defp do_swipe(_board, [], _, swiped), do: swiped

  defp do_swipe(board, [cell | to_explore], explored, swiped) do
    adjacent_cells_to_explore =
      if count_adjacent_mines(board, cell) == 0 do
        board
        |> get_adjacent_cells(cell)
        |> Enum.filter(fn adj_cell ->
          not Cell.cleared?(adj_cell) && not Enum.member?(to_explore, adj_cell) &&
            not Enum.member?(explored, adj_cell)
        end)
      else
        []
      end
    # This recursive call eventually ends because it is bounded by the explored cells set
    # It can only grow up to the size of the board.
    do_swipe(
      board,
      to_explore ++ adjacent_cells_to_explore,
      [cell | explored],
      [Cell.swipe(cell) | swiped]
    )
  end

  # Counts the amount of mines around the given `cell`
  defp count_adjacent_mines(board, cell) do
    board
    |> get_adjacent_cells(cell)
    |> Enum.count(fn cell -> Cell.mine?(cell) end)
  end

  # Returns a list of adjacent cells of `row` `col` that lay inside the board
  defp get_adjacent_cells(board, cell) do
    {row, col} = Cell.position(cell)

    [
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
      {row, col - 1},
      {row, col + 1},
      {row + 1, col - 1},
      {row + 1, col},
      {row + 1, col + 1}
    ]
    |> Enum.filter(fn
      {row, col} when is_in_board(board, row, col) -> true
      _ -> false
    end)
    |> Enum.map(fn {row, col} -> get_cell(board, row, col) end)
  end

  # Replaces all the cell positions in `cells` that occur in `updated_cells`
  defp update_cells(cells, updated_cells) do
    # Keep the unchanged cells by filtering the ones in a position that appears in
    # the list of updated cells.
    cells_not_updated =
      cells
      |> Enum.reject(fn cell ->
        updated_cells
        |> Enum.any?(fn updated_cell -> Cell.position(cell) == Cell.position(updated_cell) end)
      end)

    Enum.sort(cells_not_updated ++ updated_cells)
  end
end
