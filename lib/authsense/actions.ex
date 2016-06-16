defmodule Authsense.Actions do
  import Plug.Conn, only:
    [put_session: 3, delete_session: 2]

  @doc """
  Sets the current user for the session.

      conn
      |> Auth.set_current_user(user)
      |> put_flash(:info, "Welcome.")
      |> redirect(to: "/")

  To logout, set it to nil.

      conn
      |> Auth.set_current_user(nil)
      |> put_flash(:info, "You've been logged out.")
      |> redirect(to: "/")

  This sets the `:current_user_id` in the Session store. To access the User
  model, use `Auth` as a plug (see `Authsense.Plug`).
  """
  def set_current_user(conn, nil) do
    delete_session(conn, :current_user_id)
  end

  def set_current_user(conn, user) do
    id = Map.get(user, :id)
    put_session(conn, :current_user_id, id)
  end
end
