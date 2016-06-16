defmodule Authsense do
  @moduledoc """
  Authentication.

  ### Basic use
  Create your own module and use Authsense.

      defmodule Myapp.Auth do
        use Authsense, %{
          repo: Myapp.Auth,
          model: Myapp.User
        }
      end

  ## Usage in Controllers

  __Authenticate:__ To validate a login, use `authenticate/1`.
  (See `Authsense.Service.authenticate/2`)

      changeset = User.changeset(%User{}, user_params)
      Auth.authenticate(changeset)

      # Or you may use a tuple instead:
      Auth.authenticate({ "userid", "password" })

  __Logging in:__ Then to log in, use `set_current_user/2`.
  (See `Authsense.Actions.set_current_user/2`)

        conn
        |> Auth.set_current_user(user)
        |> put_flash(:info, "Welcome.")
        |> redirect(to: "/")

  __Logging out:__ Use the same function for logging out.

        conn
        |> Auth.set_current_user(nil)
        |> put_flash(:info, "You've been logged out.")
        |> redirect(to: "/")

  To get authentication data, use `Auth` as a plug:
  (See `Authsense.Plug`)

      plug Auth

  When using this plug, you can then get the current user:

      conn.assigns.current_user

  ## Usage in models

  In your changeset, use `generate_hashed_password/1`.
  (See `Authsense.Service.generate_hashed_password/2`)

      model
      |> cast(params, @required_fields, @optional_fields)
      |> Auth.generate_hashed_password()
      |> validate_confirmation(:password, message: "password confirmation doesn't match")
  """

  def defaults do
    %{
      crypto: Comeonin.Pbkdf2,
      identity_field: :email,
      password_field: :password,
      hashed_password_field: :hashed_password,
      login_error: "Invalid credentials.",
      repo: nil,
      model: nil
    }
  end

  defmacro __using__(opts \\ []) do
    quote do
      @auth_options Map.merge(Authsense.defaults, unquote(opts))

      def generate_hashed_password(conn), do:
        Authsense.Service.generate_hashed_password(@auth_options, conn)

      def authenticate(credentials), do:
        Authsense.Service.authenticate(@auth_options, credentials)

      def load_user(email), do:
        Authsense.Service.load_user(@auth_options, email)

      def set_current_user(conn, user), do:
        Authsense.Actions.set_current_user(conn, user)

      def init(options), do:
        Authsense.Plug.init(@auth_options, options)

      def call(conn, options), do:
        Authsense.Plug.call(@auth_options, conn, options)
    end
  end
end
