defmodule Authsense.Plug do
  @moduledoc """
  See `Authsense.call/2`.
  """

  import Plug.Conn, only:
    [get_session: 2, put_session: 3, delete_session: 2, assign: 3]

  @doc """
  Adds `:current_user` to the assigns.
  """
  def fetch_current_user(_, %Plug.Conn{assigns: %{ current_user: _ }} = conn, _) do
    conn
  end

  def fetch_current_user(%{model: model, repo: repo}, conn, _options) do
    case get_session(conn, :current_user_id) do
      nil ->
        assign(conn, :current_user, nil)
      id ->
        user = repo.get!(model, id)
        assign(conn, :current_user, user)
    end
  end

  @doc """
  See `Authsense.put_current_user/2`.
  """
  def put_current_user(conn, nil) do
    conn
    |> delete_session(:current_user_id)
    |> assign(:current_user, nil)
  end

  def put_current_user(conn, user) do
    id = Map.get(user, :id)
    conn
    |> put_session(:current_user_id, id)
    |> assign(:current_user, user)
  end
end
