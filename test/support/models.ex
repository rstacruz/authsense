defmodule Authsense.Test.User do
  use Ecto.Model
  schema "" do
    field :email, :string
    field :hashed_password, :string
    timestamps()
  end
end
