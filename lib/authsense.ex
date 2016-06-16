defmodule Authsense do
  @moduledoc """
  Sensible authentication helpers for Phoenix/Ecto.

  ### Basic use
  Create your own module and use Authsense.

      defmodule Myapp.Auth do
        use Authsense,
          repo: Myapp.Auth,
          model: Myapp.User
      end

  ## Authentication

  To validate a login, use `authenticate/1`.
  (See `Authsense.Service.authenticate/2`)

      Auth.authenticate(changeset)  #=> {:ok, user} or {:error, changeset_with_errors}
      Auth.authenticate({ "userid", "password" })  #=> %User{} | nil

  ## Logging in/out
  To log in, use `set_current_user/2`.
  (See `Authsense.Actions.set_current_user/2`)

        conn |> Auth.set_current_user(user)  # login
        conn |> Auth.set_current_user(nil)   # logout

  ## Get current user

  To get authentication data, use `Auth` as a plug:
  (See `Authsense.Plug`)

      plug Auth

  When using this plug, you can then get the current user:

      conn.assigns.current_user  #=> %User{} | nil

  ## Usage in models

  In your changeset, use `generate_hashed_password/1`.
  (See `Authsense.Service.generate_hashed_password/2`)

      model
      |> Auth.generate_hashed_password()

  ## Configuration
  Set configuration using `use Authsense, repo: Myapp.Repo, ...`. These keys are available:

  - `repo` (required) - the Ecto repo to connect to.
  - `model` (required) - the user model to use.
  - `crypto` - the crypto module to use. (default: `Comeonin.Pbkdf2`)
  - `identity_field` - field that identifies the user. (default: `:email`)
  - `password_Field` - virtual field that has the plaintext password. (default: `:password`)
  - `hashed_password_field` - field where the password is stored. (default: `:hashed_password`)
  - `login_error` - the error to add to the changeset on `Auth.authenticate/1`. (default: "Invalid credentials.")

  ## Delegate functions
  These are the available functions:

  - `Authsense.Service.generate_hashed_password/2`
  - `Authsense.Service.authenticate/2`
  - `Authsense.Service.load_user/2`
  - `Authsense.Actions.set_current_user/2`
  - `Authsense.Plug`
  """

  @doc false
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
      @auth_options Map.merge(Authsense.defaults, Enum.into(unquote(opts), %{}))

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
