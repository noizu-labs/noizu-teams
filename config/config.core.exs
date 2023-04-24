import Config

require NoizuTeams.Config.ConfigUtils
import NoizuTeams.Config.ConfigUtils

config :noizu_labs_open_ai,
       openai_api_key: NoizuTeams.Config.ConfigUtils.env_setting("OPENAI_API_KEY")

config :noizu_teams, :redis,
       host: env_setting("REDIS_HOST")

# Configure your database
config :noizu_teams, NoizuTeams.Repo,
       username: env_setting("DB_USERNAME"),
       password: env_setting("DB_PASSWORD"),
       port: env_setting("DB_PORT", as: :integer),
       hostname: env_setting("DB_HOST"),
       database: env_setting("DB_NAME"),
       stacktrace: env_setting("DB_STACKTRACE", as: :bool, default: false),
       show_sensitive_data_on_connection_error: env_setting("DB_SENSITIVE_DATA", as: :bool, default: false),
       pool_size: env_setting("DB_POOL_SIZE", as: :integer),
       primary_key: {:identifier, :uuid, autogenerate: true}