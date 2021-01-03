import Config

config :mnesia,
  # Notice the single quotes
  dir: '.mnesia/#{Mix.env()}/#{node()}'

import_config "#{Mix.env()}.exs"
