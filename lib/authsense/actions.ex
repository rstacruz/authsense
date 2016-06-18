defmodule Authsense.Actions do
  import Plug.Conn, only:
    [put_session: 3, delete_session: 2, assign: 3]

  @doc """
  See `Authsense.set_current_user/2`.
  """
  def set_current_user(conn, nil) do
    conn
    |> delete_session(:current_user_id)
    |> assign(:current_user, nil)
  end

  def set_current_user(conn, user) do
    id = Map.get(user, :id)
    conn
    |> put_session(:current_user_id, id)
    |> assign(:current_user, user)
  end
end
