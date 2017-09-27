defmodule Authsense.Test.User do
  use Ecto.Schema
  schema "" do
    field :email, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    timestamps()
  end
end
