defmodule Authsense.Test.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :hashed_password, :string
      timestamps
    end
  end
end
