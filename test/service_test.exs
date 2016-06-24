defmodule AuthsenseServiceTest do
  use ExUnit.Case
  doctest Authsense.Service
  alias Authsense.Test.Repo
  alias Authsense.Test.User
  alias Authsense.Service
  import Ecto.Changeset, only: [change: 2]

  setup do
    Repo.delete_all(User)
    :ok
  end

  def add_user do
    %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.generate_hashed_password()
    |> Repo.insert!
  end

  def get_user do
    Repo.get_by(User, email: "rico@gmail.com")
  end

  test "generate_hashed_password success" do
    add_user

    user = Repo.get_by(User, email: "rico@gmail.com")
    assert user.hashed_password |> String.starts_with?("$pbkdf2-sha512$")
  end

  test "generate_hashed_password failure" do
    %User{}
    |> change(%{email: "rico@gmail.com"})
    |> Service.generate_hashed_password()
    |> Repo.insert!

    user = Repo.get_by(User, email: "rico@gmail.com")
    assert user.hashed_password == nil
  end

  test "authenticate via changeset" do
    add_user

    assert {:ok, get_user} == %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.authenticate()
  end

  test "authenticate via changeset failure" do
    add_user

    {:error, changeset} = %User{}
    |> change(%{email: "rico@gmail.com", password: "nope"})
    |> Service.authenticate()

    assert changeset.errors == [password: "Invalid credentials."]
  end

  test "authenticate via password" do
    add_user

    assert {:error, nil} == Service.authenticate({"rico@gmail.com", "nope"})
  end

  test "get_user" do
    add_user
    assert Service.get_user("rico@gmail.com") == get_user
  end

  test "get_user failure" do
    assert Service.get_user("nobody@gmail.com") == nil
  end
end
