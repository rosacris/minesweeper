defmodule Minesweeper.Board.Cell do
  @moduledoc "Logic for board cells"

  @type payload :: :mine | :nomine
  @type status :: :unexplored | :marked | :flagged | :cleared
  @type cell :: {non_neg_integer(), non_neg_integer(), payload(), status()}

  @doc "Creates a new cell"
  @spec new(non_neg_integer(), non_neg_integer(), payload(), status()) :: cell()
  def new(row, col, payload, state), do: {row, col, payload, state}

  @doc "Returns the position of a cell"
  @spec position(cell()) :: {non_neg_integer(), non_neg_integer()}
  def position({row, col, _, _}), do: {row, col}

  @doc "Marks a cell as possible mine"
  @spec mark(cell()) :: cell()
  def mark({row, col, payload, :marked}), do: {row, col, payload, :unexplored}
  def mark({row, col, payload, :unexplored}), do: {row, col, payload, :marked}
  def mark({row, col, payload, :flagged}), do: {row, col, payload, :marked}
  def mark(_), do: raise("Invalid cell state")

  @doc "Flag a cell as a mine"
  @spec flag(cell()) :: cell()
  def flag({row, col, payload, :flagged}), do: {row, col, payload, :unexplored}
  def flag({row, col, payload, :unexplored}), do: {row, col, payload, :flagged}
  def flag({row, col, payload, :marked}), do: {row, col, payload, :flagged}
  def flag(_), do: raise("Invalid cell state")

  @doc "Swipes a cell"
  @spec swipe(cell()) :: cell()
  def swipe({row, col, payload, _}), do: {row, col, payload, :cleared}

  @doc "True if the given cell is a mine, false otherwise"
  @spec mine?(cell()) :: boolean()
  def mine?({_, _, :mine, _}), do: true
  def mine?(_), do: false

  @doc "True if the given cell is unexplored, false otherwise"
  @spec unexplored?(cell()) :: boolean()
  def unexplored?({_, _, _, :unexplored}), do: true
  def unexplored?(_), do: false

  @doc "True if the given cell is marked, false otherwise"
  @spec marked?(cell()) :: boolean()
  def marked?({_, _, _, :marked}), do: true
  def marked?(_), do: false

  @doc "True if the given cell is flagged, false otherwise"
  @spec flagged?(cell()) :: boolean()
  def flagged?({_, _, _, :flagged}), do: true
  def flagged?(_), do: false

  @doc "True if the given cell is clered, false otherwise"
  @spec cleared?(cell()) :: boolean()
  def cleared?({_, _, _, :cleared}), do: true
  def cleared?(_), do: false

  @doc "Returns a string representation of the given cell"
  @spec to_string(cell(), boolean()) :: String.t()
  def to_string(cell, adjacent_mines_count, reveal \\ false)

  def to_string(cell, adj_mines_count, false) do
    case cell do
      {_, _, :mine, :cleared} -> "*"
      {_, _, _, :unexplored} -> "#"
      {_, _, _, :flagged} -> "F"
      {_, _, _, :marked} -> "?"
      {_, _, _, :cleared} -> if adj_mines_count == 0, do: " ", else: "#{adj_mines_count}"
    end
  end

  def to_string(cell, _, true) do
    case cell do
      {_, _, :mine, _} -> "*"
      {_, _, :no_mine, _} -> " "
    end
  end
end
