defmodule Minesweeper.Board.Cell do
  @moduledoc "Logic for board cells"

  @type payload :: :mine | :nomine
  @type status :: :unexplored | :marked | :flagged | :cleared
  @type cell :: {non_neg_integer(), non_neg_integer(), payload(), status()}

  @doc "Creates a new cell"
  @spec new(non_neg_integer(), non_neg_integer(), payload(), status()) :: cell()
  def new(row, col, payload, state), do: {row, col, payload, state}

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
end
