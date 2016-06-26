use Mix.Config

if System.get_env("DATABASE_URL") do
  config :authsense, Authsense.Test.Repo,
    adapter: Ecto.Adapters.Postgres,
    pool: Ecto.Adapters.SQL.Sandbox,
    url: {:system, "DATABASE_URL"}
else
    config :authsense, Authsense.Test.Repo,
      adapter: Ecto.Adapters.Postgres,
      pool: Ecto.Adapters.SQL.Sandbox,
      username: "postgres",
      password: "postgres",
      database: "authsense_test",
      size: 10
end

config :ex_unit, :capture_log, true

config :authsense,
  Authsense.Test.User,
  repo: Authsense.Test.Repo,
  password_field: :custom_field

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
