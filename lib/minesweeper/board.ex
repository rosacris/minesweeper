defmodule Minesweeper.Board do
  @moduledoc "Minesweeper board logic implementation"

  @type payload :: :mine | :nomine
  @type status :: :unexplored | :marked | :flagged | :cleared
  @type cell :: {non_neg_integer(), non_neg_integer(), payload(), status()}
  @type board :: %{rows: non_neg_integer(), cols: non_neg_integer(), cells: list(cell())}

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
      |> Enum.map(fn {{row, col}, payload} -> {row, col, payload, :unexplored} end)

    %{rows: rows, cols: cols, cells: cells}
  end

  def swipe(), do: raise("Unimplemented")

  def mark(), do: raise("Unimplemented")

  def flag(), do: raise("Unimplemented")

  def decide(), do: raise("Unimplemented")

  @doc "True if the given cell is a mine, false otherwise"
  @spec mine?(cell()) :: boolean()
  def mine?({_, _, :mine, _}), do: true
  def mine?(_), do: false

  @doc "True if the given cell is unexplored, false otherwise"
  @spec unexplored?(cell()) :: boolean()
  def unexplored?({_, _, _, :unexplored}), do: true
  def unexplored?(_), do: false

  #
  # Private functions
  #
end
