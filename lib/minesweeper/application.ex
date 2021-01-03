defmodule Minesweeper.Application do
  @moduledoc "OTP Application specification for Minesweeper"

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Minesweeper.Endpoint,
        options: [port: Application.get_env(:minesweeper, :port)]
      )
    ]

    opts = [strategy: :one_for_one, name: Minesweeper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
