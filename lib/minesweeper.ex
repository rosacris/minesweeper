defmodule Minesweeper do
  @moduledoc """
  Documentation for `Minesweeper`.
  """

  alias Minesweeper.{Board, Game}

  @type user_id :: integer()
  @type game_id :: integer()
  @type game :: %{
          id: game_id(),
          user_id: user_id(),
          board: list(list(String.t())),
          game_status: :undecided | :won | :lost,
          started_at: DateTime.t(),
          ended_at: DateTime.t() | nil
        }
  @type error :: {:error, String.t()}

  #
  # Public API
  #

  @doc "List all user games"
  @spec list_games(user_id()) :: [game_id()]
  def list_games(user_id) do
    try do
      Game.list(user_id) |> Enum.map(fn game -> Map.fetch!(game, :id) end)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc "Starts a new game for `user_id`"
  @spec new_game(user_id(), non_neg_integer(), non_neg_integer(), non_neg_integer()) ::
          game_id() | error()
  def new_game(user_id, rows, cols, mines) do
    try do
      board = Board.new(rows, cols, mines)
      started_at = DateTime.utc_now()

      %Game{
        user_id: user_id,
        started_at: started_at,
        board: board
      }
      |> Game.new()
      |> Map.fetch!(:id)
    rescue
      e -> {:error, e.message}
    end
  end

  @doc "Returns the `game_id` for `user_id`"
  @spec get_game(user_id(), game_id(), boolean()) :: game() | error()
  def get_game(user_id, game_id, reveal \\ false) do
    case Game.get(user_id, game_id) do
      %Game{} = game ->
        %{
          id: game.id,
          user_id: game.user_id,
          started_at: game.started_at,
          ended_at: game.ended_at,
          game_status: Board.decide(game.board),
          board: Board.format(game.board, reveal)
        }

      error ->
        error
    end
  end

  @doc "Marks the cell at `row` `col` in the given user `game_id`"
  @spec mark(user_id(), game_id(), non_neg_integer(), non_neg_integer()) :: :ok | error()
  def mark(user_id, game_id, row, col) do
    change_cell(user_id, game_id, row, col, &Board.mark/3)
  end

  @doc "Flags the cell at `row` `col` in the given user `game_id`"
  @spec flag(user_id(), game_id(), non_neg_integer(), non_neg_integer()) :: :ok | error()
  def flag(user_id, game_id, row, col) do
    change_cell(user_id, game_id, row, col, &Board.flag/3)
  end

  @doc "Swipes the cell at `row` `col` in the given user `game_id`"
  @spec swipe(user_id(), game_id(), non_neg_integer(), non_neg_integer()) :: :ok | error()
  def swipe(user_id, game_id, row, col) do
    change_cell(user_id, game_id, row, col, &Board.swipe/3)
  end

  #
  # Private functions
  #

  # This is a helper function that runs an update function in a user game cell if the game
  # is not decided yet, otherwise it leaves the game unchanged.
  defp change_cell(user_id, game_id, row, col, update_function) do
    try do
      Game.update_game(user_id, game_id, fn
        # If game is not ended, run the change
        %Game{ended_at: nil} = game ->
          updated_board =
            game
            |> Map.fetch!(:board)
            |> (&update_function.(&1, row, col)).()

          # Update ended_at time if the board was decided after applying the last change
          ended_at =
            if Board.decide(updated_board) != :undecided do
              DateTime.utc_now()
            end

          %{game | board: updated_board, ended_at: ended_at}

        # Otherwise just leave the game as it is
        game ->
          game
      end)
    rescue
      e -> {:error, e.message}
    end
  end
end
