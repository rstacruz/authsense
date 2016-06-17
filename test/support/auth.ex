defmodule Auth do
  use Authsense,
    repo: Authsense.Test.Repo,
    model: Authsense.Test.User
end
