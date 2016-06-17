defmodule Authsense.Plug do
  @moduledoc """
  See `Authsense.call/2`.
  """

  import Plug.Conn, only: [get_session: 2, assign: 3]

  @doc """
  Adds `:current_user` to the assigns.
  """
  def assign_current_user(_, %Plug.Conn{assigns: %{ current_user: _ }} = conn, _) do
    conn
  end

  def assign_current_user(%{model: model, repo: repo}, conn, _options) do
    case get_session(conn, :current_user_id) do
      nil ->
        assign(conn, :current_user, nil)
      id ->
        user = repo.get!(model, id)
        assign(conn, :current_user, user)
    end
  end
end
