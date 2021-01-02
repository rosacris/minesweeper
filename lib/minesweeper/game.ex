defmodule Minesweeper.Game do
  @moduledoc "Schema representation of a Game"

  use Memento.Table,
    attributes: [:id, :user_id, :game],
    index: [:user_id],
    type: :ordered_set,
    autoincrement: true
end
