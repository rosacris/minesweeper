defmodule Minesweeper do
  @moduledoc """
  Documentation for `Minesweeper`.
  """

  alias Minesweeper.Board

  @type user_id :: integer()
  @type game_id :: integer()
  @type game :: %{
          id: game_id(),
          board: Board.board(),
          game_status: :undecided | :won | :lost,
          started_at: DateTime.t()
        }

  @doc "Starts a new game"
  @spec new_game(user_id(), non_neg_integer(), non_neg_integer(), non_neg_integer()) :: game()
  def new_game(user_id, row, cols, mines) do
    # TODO: persist created game for user
    raise "Unimplemented"
  end

  @doc "Marks the cell at `row` `col` in the given `game_id`"
  @spec mark(game_id(), non_neg_integer(), non_neg_integer()) :: :ok
  def mark(game_id, row, col) do
    # TODO: fetch game from persistence, apply change, store
    raise "Unimplemented"
  end

  @doc "Flags the cell at `row` `col` in the given `game_id`"
  @spec flag(game_id(), non_neg_integer(), non_neg_integer()) :: :ok
  def flag(game_id, row, col) do
    # TODO: fetch game from persistence, apply change, store
    raise "Unimplemented"
  end
end
