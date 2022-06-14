defmodule AuthsenseServiceTest do
  use ExUnit.Case, async: true
  doctest Authsense.Service
  alias Authsense.Test.User
  alias Authsense.Service
  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query

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

    assert changeset.errors == [password: {"Invalid credentials.", []}]
  end

  test "authenticate via password" do
    assert {:error, nil} = Service.authenticate({"rico@gmail.com", "nope"})
  end

  test "get_user" do
    assert Service.get_user("rico@gmail.com").email == "rico@gmail.com"
  end

  test "get_user failure" do
    assert Service.get_user("nobody@gmail.com") == nil
  end

  test "authenticate no_user" do
    assert {:error, _} = Service.authenticate({"nobody@gmail.com", "nope"})
  end

  test "authenticate with Ecto.Queryable scope and retrieve correctly" do
    unicorns = from u in User, where: u.extra_field == "unicorn"

    assert {:ok, _user} = %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.authenticate(scope: unicorns, model: User)
  end

  test "authenticate non Ecto.Queryable or lambda scope" do
    invalid_scope = "Not a valid scope"

    assert_raise Authsense.InvalidScopeException, fn ->
      %User{}
      |> change(%{email: "rico@gmail.com", password: "foobar"})
      |> Service.authenticate(scope: invalid_scope, model: User)
    end
  end

  test "authenticate with lambda scope that returns Ecto.Queryable and retrieve correctly" do
    get_unicorns_query = fn ->
      from u in User, where: u.extra_field == "unicorn"
    end

    assert {:ok, _user} = %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.authenticate(scope: get_unicorns_query, model: User)
  end

  test "authenticate with invalid lambda scope" do
    invalid_lambda = fn -> "Not an Ecto Query return value" end

    assert_raise Authsense.InvalidScopeException, fn ->
      %User{}
      |> change(%{email: "rico@gmail.com", password: "foobar"})
      |> Service.authenticate(scope: invalid_lambda, model: User)
    end
  end
end
