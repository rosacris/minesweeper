defmodule Minesweeper.EndpointTest do
  @moduledoc """
  Tests for the API endpoints.

  Note that the tests in this module cover the ends point mappings with the use cases.
  Game logic is covered by the tests in `Minesweeper.BoardTest`module.
  """
  use ExUnit.Case, async: false
  use Plug.Test

  alias Minesweeper.Endpoint

  @opts Endpoint.init([])

  setup do
    # Clear test database before each test or create the database if doesn't exist
    case Memento.Table.clear(Minesweeper.Game) do
      :ok -> :ok
      {:error, {:no_exists, Minesweeper.Game}} -> Minesweeper.Console.setup!()
    end
  end

  test "Creates a game" do
    # Parameters of the game to create
    rows = 5
    cols = 5
    mines = 10

    game = new_game(rows, cols, mines)

    # Game is created as undecided
    assert game["game_status"] == "undecided"

    # Board has proper dimensions
    assert game["board"] |> length() == rows
    assert game["board"] |> Enum.all?(fn row -> length(row) == cols end)

    # Game board is unexplored
    assert game["board"] |> Enum.all?(fn row -> Enum.all?(row, fn cell -> cell == "#" end) end)
  end

  test "Get an existing game" do
    # Create a game
    game = new_game(10, 10, 10)

    # Fetch the game again and check it is the same
    game_id = Map.get(game, "id")
    assert get_game(game_id) == game
  end

  test "List games" do
    games = [
      new_game(10, 10, 10) |> Map.fetch!("id"),
      new_game(10, 10, 10) |> Map.fetch!("id"),
      new_game(10, 10, 10) |> Map.fetch!("id")
    ]
    game_ids = list_games()
    assert game_ids == games
  end

  test "Mark, Flag and Swipe a cell" do
    # Create a game
    game_id = new_game(10, 10, 10) |> Map.get("id")

    # Mark a cell
    cell = %{"row" => "2", "col" => "2", "status" => "?"}
    conn = conn(:put, "/games/#{game_id}/board", cell) |> Endpoint.call(@opts)
    assert conn.status == 200

    # Fetch game again and check the cell was updated
    updated_game = get_game(game_id)
    assert updated_game["board"] |> Enum.at(2) |> Enum.at(2) == "?"

    # Flag a cell
    cell = %{"row" => "4", "col" => "4", "status" => "F"}
    conn = conn(:put, "/games/#{game_id}/board", cell) |> Endpoint.call(@opts)
    assert conn.status == 200

    # Fetch game again and check the cell was updated
    updated_game = get_game(game_id)
    assert updated_game["board"] |> Enum.at(4) |> Enum.at(4) == "F"

    # Swipe a cell
    cell = %{"row" => "6", "col" => "6", "status" => " "}
    conn = conn(:put, "/games/#{game_id}/board", cell) |> Endpoint.call(@opts)
    assert conn.status == 200

    # Fetch game again and check the cell was updated
    updated_cell =
      game_id
      |> get_game()
      |> Map.get("board")
      |> Enum.at(6)
      |> Enum.at(6)

    refute updated_cell == "#"
  end

  #
  # Private functions
  #

  defp new_game(cols, rows, mines) do
    conn(:post, "/games?rows=#{rows}&cols=#{cols}&mines=#{mines}")
    |> Endpoint.call(@opts)
    |> Map.get(:resp_body)
    |> Poison.decode!()
  end

  defp get_game(game_id) do
    conn(:get, "/games/#{game_id}")
    |> Endpoint.call(@opts)
    |> Map.get(:resp_body)
    |> Poison.decode!()
  end

  defp list_games() do
    conn(:get, "/games")
    |> Endpoint.call(@opts)
    |> Map.get(:resp_body)
    |> Poison.decode!()
  end
end
