import Config

require NoizuTeams.Config.ConfigUtils
import NoizuTeams.Config.ConfigUtils


config :noizu_teams, :redis,
       host: env_setting("REDIS_HOST")
