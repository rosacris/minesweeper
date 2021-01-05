import Config

if config_env() == :prod do
  config :minesweeper, port: System.get_env("MINESWEEPER_PORT", "4001") |> String.to_integer()
end
