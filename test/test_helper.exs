ExUnit.start()

Mix.Task.run "ecto.drop", ["--quiet", "-r", "Authsense.Test.Repo"]
Mix.Task.run "ecto.create", ["--quiet", "-r", "Authsense.Test.Repo"]
Mix.Task.run "ecto.migrate", ["--quiet", "-r", "Authsense.Test.Repo"]

Authsense.Test.Repo.start_link

Ecto.Adapters.SQL.begin_test_transaction(Authsense.Test.Repo)
