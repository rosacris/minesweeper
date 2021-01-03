defmodule Minesweeper.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """
  use Plug.Router

  #
  # Plug pipeline
  #

  # Request logger
  plug(Plug.Logger)

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
  get "/games" do
    send_resp(conn, 200, "Not implemented")
  end

  # Gets single game
  get "/games/:game_id" do
    send_resp(conn, 200, "Not implemented")
  end

  # Creates a new game
  post "/games/" do
    send_resp(conn, 200, "Not implemented")
  end

  # Changes a cell in the board of a game (for marking, flagging, swiping)
  put "/games/:game_id/board" do
    send_resp(conn, 200, "Not implemented")
  end

  # Catchall route
  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end
end
