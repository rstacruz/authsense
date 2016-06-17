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
  `authenticate/1` will validate a login.

      Auth.authenticate(changeset)  #=> {:ok, user} or {:error, changeset_with_errors}
      Auth.authenticate({ "userid", "password" })  #=> %User{} | nil

  ## Logging in/out
  `set_current_user/2` will set session variables for logging in or out.

        conn |> Auth.set_current_user(user)  # login
        conn |> Auth.set_current_user(nil)   # logout

  ## Get current user
  `call/2` - to get authentication data, use `Auth` as a plug:

      plug Auth

  When using this plug, you can then get the current user:

      conn.assigns.current_user  #=> %User{} | nil

  ## Usage in models
  `generate_hashed_password/1` will update `:hashed_password` in a user changeset.

      User.changeset(...)
      |> Auth.generate_hashed_password()

  ## Configuration
  Set configuration using `use Authsense, repo: Myapp.Repo, ...`. These keys are available:

  - `repo` (required) - the Ecto repo to connect to.
  - `model` (required) - the user model to use.
  - `crypto` - the crypto module to use. (default: `Comeonin.Pbkdf2`)
  - `identity_field` - field that identifies the user. (default: `:email`)
  - `password_field` - virtual field that has the plaintext password. (default: `:password`)
  - `hashed_password_field` - field where the password is stored. (default: `:hashed_password`)
  - `login_error` - the error to add to the changeset on `Auth.authenticate/1`. (default: "Invalid credentials.")
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

  @doc """
  Updates an `Ecto.Changeset` to generate a hashed password.
  
  If the changeset has `:password` in it, it will be hashed and stored as
  `:hashed_password`.  (Fields can be configured in `Authsense`.)

      changeset
      |> Auth.generate_hashed_password()

  It's typically used in a model's `changeset/2` function.

      defmodule Example.User do
        use Example.Web, :model

        def changeset(model, params \\ :empty) do
          model
          |> cast(params, @required_fields, @optional_fields)
          |> Auth.generate_hashed_password()
          |> validate_confirmation(:password, message: "password confirmation doesn't match")
          |> unique_constraint(:email)
        end
      end

  Also see `Authsense.Service.generate_hashed_password/2` for the underlying
  implementation.
  """
  @callback generate_hashed_password(Ecto.Changeset.t) :: Ecto.Changeset.t

  @doc """
  Checks if someone can authenticate. Works on both Ecto changesets or tuples.

      def login_create(conn, %{"user" => user_params}) do
        changeset = User.changeset(%User{}, user_params)
        case Auth.authenticate(changeset) do
          {:ok, user} ->
            conn
            |> Auth.set_current_user(user)
            |> put_flash(:info, "Welcome.")
            |> redirect(to: "/")
          {:error, changeset} ->
            render(conn, "login.html", changeset: changeset)
        end
      end
  """
  @callback authenticate(Ecto.Changeset.t | { String.t, String.t }) ::
    {:error, Ecto.Changeset.t} |
    {:error, nil} |
    {:ok, Ecto.Schema.t}

  @doc """
  Loads a user by a given identity field value. Returns a nil on failure.

      load_user("rico@gmail.com")  #=> %User{...}
  """
  @callback load_user(String.t) ::
    Ecto.Schema.t | nil

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
  @callback set_current_user(Plug.Conn.t, Ecto.Schema.t | nil) ::
    Plug.Conn.t

  @doc """
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
  @callback call(Plug.Conn.t, any) :: Plug.Conn.t
  @callback init(Plug.Conn.t, any) :: nil

  defmacro __using__(opts \\ []) do
    quote do
      @behaviour Authsense
      @auth_options Map.merge(Authsense.defaults, Enum.into(unquote(opts), %{}))

      def generate_hashed_password(changeset), do:
        Authsense.Service.generate_hashed_password(@auth_options, changeset)

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
