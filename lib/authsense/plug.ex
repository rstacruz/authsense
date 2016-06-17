defmodule Authsense.Plug do
  @moduledoc """
  See `Authsense.call/2`.
  """

  import Plug.Conn, only: [get_session: 2, assign: 3]

  @doc false
  def init(%{}, _options), do: nil

  @doc """
  Adds `:current_user` to the assigns.
  """
  def call(%{model: model, repo: repo}, conn, nil) do
    if Map.has_key?(conn.assigns, :current_user) do
      conn
    else
      case get_session(conn, :current_user_id) do
        nil ->
          assign(conn, :current_user, nil)
        id ->
          user = repo.get!(model, id)
          assign(conn, :current_user, user)
      end
    end
  end
end
