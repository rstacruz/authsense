defmodule PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import Ecto.Changeset, only: [change: 2]

  alias Authsense.Test.Repo
  alias Authsense.Test.User
  alias Authsense.Test.ProcessStore
  alias Authsense.Service

  setup do
    Repo.delete_all(User)
    :ok
  end

  defp add_user do
    %User{}
    |> change(%{email: "rico@gmail.com", password: "foobar"})
    |> Service.generate_hashed_password()
    |> Repo.insert!
  end

  # Enables sessions in a conn
  defp sign_conn(conn) do
    opts = Plug.Session.init(store: ProcessStore, key: "foobar")
    conn
    |> Plug.Session.call(opts)
    |> fetch_session
  end

  test "put_current_user(user)" do
    user = add_user
    conn = conn(:get, "/")
    |> sign_conn()
    |> Authsense.Plug.put_current_user(user)

    assert conn.assigns.current_user == user
    assert get_session(conn, :current_user_id) == user.id
  end

  test "put_current_user(nil)" do
    conn = conn(:get, "/")
    |> sign_conn()
    |> Authsense.Plug.put_current_user(nil)

    assert conn.assigns.current_user == nil
    assert get_session(conn, :current_user_id) == nil
  end

  test "fetch_current_user" do
    user = add_user
    conn = conn(:get, "/")
    |> sign_conn()
    |> put_session(:current_user_id, user.id)
    |> Authsense.Plug.fetch_current_user()

    assert get_session(conn, :current_user_id) == user.id
    assert conn.assigns.current_user == user
  end
end
