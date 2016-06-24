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

  @doc """
  Retrieves default configuration.

  See `config/1` for more info.
  """
  def config do
    config(nil)
  end

  @doc """
  Retrieves configuration for a given model.

      > Authsense.config
      %{ model: Example.User, repo: Example.Repo, ... }

  If there are multiple configurations, you can pass a `model`.

      > Authsense.config(Example.User)
      %{ model: Example.User, repo: Example.Repo, ... }

  You may also pass a list. Any values other than `model` will be added in.

      > Authsense.config(model: Example.User, foo: :bar)
      %{ model: Example.User, ... foo: :bar }
  """
  def config(nil) do
    [ conf | _ ] = all_env
    { model, conf } = conf
    conf
    |> Enum.into(%{ model: model })
    |> Enum.into(@defaults)
  end

  def config(opts) when is_list(opts) do
    model = opts[:model]

    conf =
    (Keyword.get(all_env, model) || [])
      |> Enum.into(%{ model: model })
      |> Enum.into(@defaults)

    Enum.into(opts, conf)
  end

  def config(model) do
    (Keyword.get(all_env, model) || [])
    |> Enum.into(%{ model: model })
    |> Enum.into(@defaults)
  end

  # Returns configuration concerning :authsense; strips away any configuration
  # that doesn't fit.
  defp all_env do
    Application.get_all_env(:authsense)
    |> Enum.filter(fn
       {_model, [_] = list} -> Keyword.has_key?(list, :repo)
       _ -> false
    end)
  end
end
