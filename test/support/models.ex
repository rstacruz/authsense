defmodule Authsense.Test.User do
  use Ecto.Model
  schema "" do
    field :email, :string
    field :hashed_password, :string
    field :extra_field, :string
    timestamps
  end
end
