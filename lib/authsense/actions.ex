defmodule Authsense.Actions do
  import Plug.Conn, only:
    [put_session: 3, delete_session: 2]

  @doc """
  Sets the current user for the session.

      conn
      |> set_current_user(user)

  To logout, set it to nil.

      conn
      |> set_current_user(nil)
  """
  def set_current_user(conn, nil) do
    delete_session(conn, :current_user_id)
  end

  def set_current_user(conn, user) do
    id = Map.get(user, :id)
    put_session(conn, :current_user_id, id)
  end
end
