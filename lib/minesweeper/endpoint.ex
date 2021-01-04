defmodule Minesweeper.Endpoint do
  @moduledoc """
  A router for the non authenticated endpoints
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

  # Logins a user
  post "/login" do
    %{"username" => username, "password" => password} = conn.body_params

    case Minesweeper.User.login(username, password) do
      {:error, _} -> send_resp(conn, 401, "")
      token -> send_resp(conn, 200, Poison.encode!(%{token: token}))
    end
  end

  forward("/games", to: Minesweeper.AuthRouter)
end
