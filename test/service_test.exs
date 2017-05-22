defmodule AuthsenseServiceTest do
  use ExUnit.Case, async: true
  doctest Authsense.Service
  alias Authsense.Test.User
  alias Authsense.Service
  import Ecto.Changeset, only: [change: 2]

  setup do
    Application.delete_env :authsense, :included_applications
    :ok
  end

  test "generate_hashed_password success" do
    changeset =
      %User{}
      |> change(%{email: "rico@gmail.com", password: "foobar"})
      |> Service.generate_hashed_password()

    assert changeset.changes.hashed_password
      |> String.starts_with?("$pbkdf2-sha512$")
  end

  test "generate_hashed_password failure" do
    changeset =
      %User{}
      |> change(%{email: "rico@gmail.com"})
      |> Service.generate_hashed_password()

    refute Map.has_key? changeset.changes, :hashed_password
  end

  test "authenticate via changeset" do
    assert {:ok, _user} = %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.authenticate()
  end

  test "authenticate via changeset failure" do
    {:error, changeset} = %User{}
    |> change(%{email: "rico@gmail.com", password: "nope"})
    |> Service.authenticate()

    assert changeset.errors == [password: "Invalid credentials."]
  end

  test "authenticate via password" do
    assert {:error, nil} == Service.authenticate({"rico@gmail.com", "nope"})
  end

  test "get_user" do
    assert Service.get_user("rico@gmail.com").email == "rico@gmail.com"
  end

  test "get_user failure" do
    assert Service.get_user("nobody@gmail.com") == nil
  end

    test "authenticate with extra filters" do
      assert {:ok, _user} = %User{}
      |> change(%{email: "jekku@gmail.com", password: "barfoo"})
      |> Service.authenticate(nil, %{extra_field: "newbie"})

      assert {:error, _error} = %User{}
      |> change(%{email: "jekku@gmail.com", password: "barfoo"})
      |> Service.authenticate(nil, %{extra_field: "unicorn"})
    end
end
