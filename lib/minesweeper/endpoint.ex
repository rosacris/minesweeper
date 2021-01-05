defmodule Minesweeper.Endpoint do
  @moduledoc """
  A router for the non authenticated endpoints
  """
  use Plug.Router
  use Plug.ErrorHandler

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
      {:error, _} -> send_resp(conn, 401, Poison.encode!(%{message: "Invalid credentials"}))
      token -> send_resp(conn, 200, Poison.encode!(%{token: token}))
    end
  end

  forward("/games", to: Minesweeper.AuthRouter)

  # Catchall route
  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.puts("Kind:")
    IO.inspect(kind)
    IO.puts("Reason:")
    IO.inspect(reason)
    IO.puts("Stack")
    IO.inspect(stack)
    send_resp(conn, conn.status, Poison.encode!(%{message: "Something went wrong"}))
  end
end
