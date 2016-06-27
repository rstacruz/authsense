use Mix.Config

config :ex_unit, :capture_log, true

config :authsense, Authsense.Test.User,
  repo: Authsense.Test.Repo

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
