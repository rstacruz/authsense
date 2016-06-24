defmodule Authsense do
  @moduledoc """
  Sensible authentication helpers for Phoenix/Ecto.

  ### Basic use
  Create your own module and use Authsense.

      config :authsense, Myapp.Model,
        repo: Myapp.Repo

  ## Authentication
  `Authsense.Service.authenticate/2` will validate a login.

      authenticate(changeset)  #=> {:ok, user} or {:error, changeset_with_errors}
      authenticate({ "userid", "password" })  #=> %User{} | nil

  ## Logging in/out
  `Authsense.Plug.put_current_user/2` will set session variables for logging in or out.

        conn |> put_current_user(user)  # login
        conn |> put_current_user(nil)   # logout

  ## Get current user
  `Authsense.Plug.fetch_current_user/2` - to get authentication data, use `Auth` as a plug:

      # controller
      import Authsense.Plug
      plug :fetch_current_user

  When using this plug, you can then get the current user:

      conn.assigns.current_user  #=> %User{} | nil

  ## Usage in models
  `Authsense.Service.generate_hashed_password/2` will update `:hashed_password` in a user changeset.

      User.changeset(...)
      |> generate_hashed_password()

  ## Configuration
  These keys are available:

  - `repo` (required) - the Ecto repo to connect to.
  - `model` (required) - the user model to use.
  - `crypto` - the crypto module to use. (default: `Comeonin.Pbkdf2`)
  - `identity_field` - field that identifies the user. (default: `:email`)
  - `password_field` - virtual field that has the plaintext password. (default: `:password`)
  - `hashed_password_field` - field where the password is stored. (default: `:hashed_password`)
  - `login_error` - the error to add to the changeset on `Auth.authenticate/1`. (default: "Invalid credentials.")

  ## Recipes

  For information on how to build login pages, secure your website, and other
  things: see [Recipes](recipes.html).
  """

  @doc false
  @defaults %{
    crypto: Comeonin.Pbkdf2,
    identity_field: :email,
    password_field: :password,
    hashed_password_field: :hashed_password,
    login_error: "Invalid credentials.",
    repo: nil,
    model: nil
  }

  @callback put_current_user(Plug.Conn.t, Ecto.Schema.t | nil) ::
    Plug.Conn.t

  def config do
    config(nil)
  end

  def config(nil) do # no model
    [ _, conf | _ ] = Application.get_all_env(:authsense)
    { model, conf } = conf
    conf
    |> Enum.into(%{ model: model })
    |> Enum.into(@defaults)
  end

  def config(model) do
    [ _ | conf ] = Application.get_all_env(:authsense)
    conf = Keyword.get(conf, model)
    { model, conf } = conf
    conf
    |> Enum.into(%{ model: model })
    |> Enum.into(@defaults)
  end
end
