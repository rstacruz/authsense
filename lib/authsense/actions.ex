defmodule Authsense.Actions do
  import Plug.Conn, only:
    [put_session: 3, delete_session: 2]

  @doc """
  See `Authsense.set_current_user/2`.
  """
  def set_current_user(conn, nil) do
    delete_session(conn, :current_user_id)
  end

  def set_current_user(conn, user) do
    id = Map.get(user, :id)
    put_session(conn, :current_user_id, id)
  end
end
