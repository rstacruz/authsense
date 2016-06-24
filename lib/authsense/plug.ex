defmodule Authsense.Plug do
  @moduledoc """
  See `Authsense.call/2`.
  """

  import Plug.Conn, only:
    [get_session: 2, put_session: 3, delete_session: 2, assign: 3]

  @doc """
  Sets the `:current_user` assigns variable based on session.

      defmodule Auth do
        use Authsense, # ...
      end

      # in your controller or pipeline:
      import Auth
      plug :fetch_current_user

  By doing so, you'll get access to the `:current_user` assigns. It will be set
  to the User model if logged in, or to `nil` if logged out.

      conn.assigns.current_user

      <%= if @current_user %>
        Hello, <%= @current_user.name %>
      <% else %>
        You are not logged in.
      <% end %>
  """
  def fetch_current_user(%Plug.Conn{assigns: %{ current_user: _ }} = conn, _) do
    conn
  end

  def fetch_current_user(conn, opts \\ []) do
    %{repo: repo, model: model} = Authsense.config(opts)

    case get_session(conn, :current_user_id) do
      nil ->
        assign(conn, :current_user, nil)
      id ->
        user = try do
          repo.get!(model, id)
        rescue _ ->
          # Protection against "logged in" users whos accounts get deleted.
          nil
        end
        assign(conn, :current_user, user)
    end
  end

  @doc """
  Sets the current user for the session.

      conn
      |> Auth.put_current_user(user)
      |> put_flash(:info, "Welcome.")
      |> redirect(to: "/")

  To logout, set it to nil.

      conn
      |> Auth.put_current_user(nil)
      |> put_flash(:info, "You've been logged out.")
      |> redirect(to: "/")

  This sets the `:current_user_id` in the Session store. To access the User
  model, use `Auth` as a plug (see `Authsense.Plug`).
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
