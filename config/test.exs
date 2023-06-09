import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

# Configure your database
config :noizu_teams, NoizuTeams.Repo,
       pool: Ecto.Adapters.SQL.Sandbox


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :noizu_teams, NoizuTeamsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "E1YoU3b5TPGkxsCuSCb9XIYcaae/a/+5Kbwpe9gcNOYmDq5KNxNuUBVBKp/an/H5",
  server: false

# In test we don't send emails.
config :noizu_teams, NoizuTeams.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
