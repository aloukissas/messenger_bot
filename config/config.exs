# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :messenger_bot,
  ecto_repos: [MessengerBot.Repo]

# Configures the endpoint
config :messenger_bot, MessengerBotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5kgPcUriW7NxcBg+LRDEkQIRMNehiD3bOCGX03YG2oE8fnfyi942NzxkskrZ4wnI",
  render_errors: [view: MessengerBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MessengerBot.PubSub,
  live_view: [signing_salt: "Wp4bqRjo"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
