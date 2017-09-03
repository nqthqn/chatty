# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chatty,
  ecto_repos: [Chatty.Repo]

# Configures the endpoint
config :chatty, Chatty.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R1B3Im+6aqQnQ8z3oY/HOO9DPgIs1NLW8r/NDA0Be+kR1g+HzdAxDu+B7wiVZzTG",
  render_errors: [view: Chatty.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Chatty.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
