defmodule Minesweeper.Auth do
  @moduledoc """
  Simple authentication plug that validates a header token

  We provide a simple authentication mechanism were user requests are authorized based on a token obtained
  via the login endpoint. The tokens expire after one hour.
  """

  import Plug.Conn

  alias Minesweeper.User

  def init(default), do: default

  def call(conn, _) do
    conn
    |> get_auth_header()
    |> authenticate()
  end

  #
  # Private functions
  #

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> {conn, token}
      _ -> {conn}
    end
  end

  defp authenticate({conn, token}) do
    case User.validate_token(token) do
      {:error, _} -> send_401(conn)
      id -> assign(conn, :user_id, id)
    end
  end

  defp authenticate({conn}) do
    send_401(conn)
  end

  defp send_401(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Poison.encode!(%{message: "Invalid authentication header"}))
    |> halt
  end
end
