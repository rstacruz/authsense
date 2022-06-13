import Config

config :ex_unit, :capture_log, true

config :authsense, Authsense.Test.User,
  repo: Authsense.Test.Repo

config :comeonin, :pbkdf2_rounds, 1
