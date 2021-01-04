defmodule Minesweeper.AuthRouter do
  @moduledoc """
  A router for the authenticated endpoints
  """
  use Plug.Router

  #
  # Plug pipeline
  #

  # Request logger
  plug(Plug.Logger)

  plug(Minesweeper.Auth)

  # Routes matcher
  plug(:match)

  # JSON decoder
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Poison)

  # Dispatch responses
  plug(:dispatch)

  #
  # Routes
  #

  # Lists games
  get "/" do
    try do
      game_ids = Minesweeper.list_games(conn.assigns.user_id)
      send_resp(conn, 200, Poison.encode!(game_ids))
    rescue
      e -> send_resp(conn, 400, error_message(e.message))
    end
  end

  # Gets single game
  get ":game_id" do
    try do
      game_id = String.to_integer(game_id)
      game = Minesweeper.get_game(conn.assigns.user_id, game_id, false)
      send_resp(conn, 200, Poison.encode!(game))
    rescue
      e -> send_resp(conn, 400, error_message(e.message))
    end
  end

  # Creates a new game
  post "/" do
    try do
      # Parse call parameters
      conn = fetch_query_params(conn)
      %{"rows" => rows_param, "cols" => cols_param, "mines" => mines_param} = conn.params
      rows = String.to_integer(rows_param)
      cols = String.to_integer(cols_param)
      mines = String.to_integer(mines_param)

      # Execute request
      action_result = Minesweeper.new_game(conn.assigns.user_id, rows, cols, mines)

      # Generate response
      case action_result do
        {:error, message} ->
          send_resp(conn, 400, error_message(message))

        game_id ->
          # Fetch game and send response
          game = Minesweeper.get_game(conn.assigns.user_id, game_id)
          send_resp(conn, 201, Poison.encode!(game))
      end
    rescue
      e -> send_resp(conn, 400, error_message(e.message))
    end
  end

  # Changes a cell in the board of a game (for marking, flagging, swiping)
  put "/:game_id/board" do
    try do
      # Parse call parameters
      game_id = String.to_integer(game_id)
      %{"row" => row, "col" => col, "status" => status} = conn.body_params
      user_id = conn.assigns.user_id

      # Execute request
      action_result =
        case status do
          "?" -> Minesweeper.mark(user_id, game_id, row, col)
          "F" -> Minesweeper.flag(user_id, game_id, row, col)
          " " -> Minesweeper.swipe(user_id, game_id, row, col)
          _ -> {:error, "Invalid status"}
        end

      # Generate response
      case action_result do
        :ok -> send_resp(conn, 200, "")
        {:error, message} -> send_resp(conn, 400, error_message(message))
      end
    rescue
      e -> send_resp(conn, 400, error_message(e.message))
    end
  end

  # Catchall route
  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  #
  # Private functions
  #

  defp error_message(message) do
    Poison.encode!(%{message: message})
  end
end
