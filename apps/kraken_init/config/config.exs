import Config

config :kraken,
  project_start: false

import_config "#{config_env()}.exs"
