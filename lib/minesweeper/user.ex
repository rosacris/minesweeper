defmodule Minesweeper.User do
  @moduledoc "Schema representation of a user"

  use Memento.Table,
    attributes: [:id, :username, :password, :token, :expires_at],
    index: [:username],
    type: :ordered_set,
    autoincrement: true

  @doc "Adds a new user"
  def add(username, password, token \\ nil) do
    user = %__MODULE__{
      username: username,
      password: password,
      token: token
    }

    Memento.transaction!(fn -> Memento.Query.write(user) end)
  end

  @doc "Login a user and return authorization token"
  def login(username, password) do
    Memento.transaction!(fn ->
      guards = [
        {:==, :username, username},
        {:==, :password, password}
      ]

      case Memento.Query.select(__MODULE__, guards) do
        [%__MODULE__{} = user] ->
          token = :crypto.hash(:sha256, "whatever") |> Base.encode16()
          expires_at = DateTime.utc_now() |> DateTime.add(3600, :second)

          %{user | token: token, expires_at: expires_at}
          |> Memento.Query.write()

          token

        [] ->
          {:error, "Unauthorized"}
      end
    end)
  end

  @doc "Validates a token and returns the user_id owning the token"
  def validate_token(token) do
    Memento.transaction!(fn ->
      case Memento.Query.select(__MODULE__, {:==, :token, token}) do
        [%__MODULE__{id: id, expires_at: expires_at}] ->
          case DateTime.compare(expires_at, DateTime.utc_now()) do
            :gt -> id
            _ -> {:error, "Unauthorized"}
          end

        _ ->
          {:error, "Unauthorized"}
      end
    end)
  end
end
