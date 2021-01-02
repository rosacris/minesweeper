defmodule Minesweeper.Game do
  @moduledoc "Schema representation of a Game"

  use Memento.Table,
    attributes: [:id, :user_id, :started_at, :board],
    index: [:user_id],
    type: :ordered_set,
    autoincrement: true

  @doc "Creates a new `game`"
  @spec new(Memento.Table.record()) :: Memento.Table.record()
  def new(game) do
    Memento.transaction!(fn -> Memento.Query.write(game) end)
  end

  @doc "Returns the game with the given `id` for `user_id` or error if does not exist"
  @spec get(Minesweeper.user_id(), non_neg_integer()) ::
          Memento.Table.record() | {:error, String.t()}
  def get(user_id, id) do
    Memento.transaction!(fn ->
      case Memento.Query.read(__MODULE__, id) do
        %__MODULE__{user_id: ^user_id} = game -> game
        %__MODULE__{} -> {:error, "Unauthorized"}
        nil -> {:error, "Game not found"}
      end
    end)
  end

  @doc "Updates a game in a transaction using the provided function"
  @spec update_game(
          Minesweeper.user_id(),
          non_neg_integer(),
          (Memento.Table.record() -> Memento.Table.record())
        ) ::
          :ok | {:error, String.t()}
  def update_game(user_id, id, update_function) do
    Memento.transaction!(fn ->
      case Memento.Query.read(__MODULE__, id) do
        %__MODULE__{user_id: ^user_id} = game ->
          updated_game = update_function.(game)
          Memento.Query.write(updated_game)
          :ok

        %__MODULE__{} ->
          {:error, "Unauthorized"}

        nil ->
          {:error, "Game not found"}
      end
    end)
  end
end
