defmodule Authsense.Plug do
  @moduledoc """
  Authsense can be used as a plug.

      defmodule Auth do
        use Authsense, %{ ... }
      end

      # in your controller:
      plug Auth

  By doing so, you'll get access to the `:current_user` assigns. It will be set
  to the User model if logged in, or to `nil` if logged out.

      conn.assigns.current_user

      <%= if @current_user %>
        Hello, <%= @current_user.name %>
      <% else %>
        You are not logged in.
      <% end %>
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
