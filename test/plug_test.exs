defmodule PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Authsense.Test.User
  alias Authsense.Test.ProcessStore

  setup do
    Application.delete_env :authsense, :included_applications
    :ok
  end

  # Enables sessions in a conn
  defp sign_conn(conn) do
    opts = Plug.Session.init(store: ProcessStore, key: "foobar")
    conn
    |> Plug.Session.call(opts)
    |> fetch_session
  end

  test "put_current_user(user)" do
    user = %User{id: 1}
    conn = conn(:get, "/")
    |> sign_conn()
    |> Authsense.Plug.put_current_user(user)

    assert conn.assigns.current_user == user
    assert get_session(conn, :current_user_id) == 1
  end

  test "put_current_user(nil)" do
    conn = conn(:get, "/")
    |> sign_conn()
    |> Authsense.Plug.put_current_user(nil)

    assert conn.assigns.current_user == nil
    assert get_session(conn, :current_user_id) == nil
  end

  test "fetch_current_user" do
    user = %User{id: 1}
    conn = conn(:get, "/")
    |> sign_conn()
    |> put_session(:current_user_id, user.id)
    |> Authsense.Plug.fetch_current_user()

    assert get_session(conn, :current_user_id) == user.id
    assert conn.assigns.current_user.id == user.id
  end

  test "fetch_current_user (nonexistent)" do
    conn = conn(:get, "/")
    |> sign_conn()
    |> put_session(:current_user_id, 31337) # presumably non-existent
    |> Authsense.Plug.fetch_current_user()

    assert get_session(conn, :current_user_id) == 31337
    assert conn.assigns.current_user == nil
  end
end
