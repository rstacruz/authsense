defmodule Authsense.Test.User do
  use Ecto.Schema
  schema "" do
    field :email, :string
    field :hashed_password, :string
    timestamps()
  end
end
