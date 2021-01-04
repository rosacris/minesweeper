defmodule Minesweeper.Console do
  @moduledoc false

  @spec setup!(nodes :: list(node)) :: :ok
  def setup!(nodes \\ [node()]) do
    # Create the DB directory (if custom path given)
    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end

    # Create the Schema
    Memento.stop()
    Memento.Schema.create(nodes)
    Memento.start()
    Memento.Table.create!(Minesweeper.User, disc_copies: nodes)
    Memento.Table.create!(Minesweeper.Game, disc_copies: nodes)
  end
end
