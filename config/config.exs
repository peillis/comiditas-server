# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :comiditas,
  ecto_repos: [Comiditas.Repo]

# Configures the endpoint
config :comiditas, ComiditasWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gkhN1m/WtaBdvhcYNDUYR80JGAm9GBPUwQDkMeFaQI3LO0qUCSb432wF5PkWZTI8",
  render_errors: [view: ComiditasWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Comiditas.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "1Ru6vfK2g5cLBb0CHzo8SXcswtPrmo05I8aD9/wqSXTdy8i4MLMT5viEtOEp6lhi"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :torch,
  otp_app: :comiditas,
  template_format: "eex" || "slim"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
