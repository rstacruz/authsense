defmodule Authsense.Service do
  import Ecto.Changeset, only:
    [get_change: 2, put_change: 3, validate_change: 3]

  alias Ecto.Changeset

  @doc """
  Checks if someone can authenticate with a given username/password pair.

  Works on both Ecto changesets or tuples.

      %User{}
      |> change(%{ email: "rico@gmail.com", password: "password" })
      |> Auth.authenticate

      Auth.authenticate({ "rico@gmail.com", "password" })

  Returns `{:ok, user}` on success, or `{:error, changeset}` on failure. If
  used as a tuple, it returns `{:error, nil}` on failure.

  Typically used within a login action.

      def login_create(conn, %{"user" => user_params}) do
        changeset = User.changeset(%User{}, user_params)

        case Auth.authenticate(changeset) do
          {:ok, user} ->
            conn
            |> Auth.put_current_user(user)
            |> put_flash(:info, "Welcome.")
            |> redirect(to: "/")

          {:error, changeset} ->
            render(conn, "login.html", changeset: changeset)
        end
      end
  """
  def authenticate(credentials, model \\ nil) do
    case authenticate_user(credentials, model) do
      false -> {:error, auth_failure(credentials)}
      user -> {:ok, user}
    end
  end

  @doc """
  Returns the user associated with these credentials. Returns the User record
  on success, or `false` on error.

  Accepts both `{ email, password }` tuples and `Ecto.Changeset`s.

      authenticate_user(changeset)
      authenticate_user({ email, password })
  """
  def authenticate_user(changeset_or_tuple, model \\ nil)
  def authenticate_user(%Changeset{} = changeset, model) do
    %{identity_field: id, password_field: passwd} =
      Authsense.config(model)

    email = get_change(changeset, id)
    password = get_change(changeset, passwd)
    authenticate_user({email, password}, model)
  end

  def authenticate_user({email, password}, model) do
    %{crypto: crypto, hashed_password_field: hashed_passwd} =
      Authsense.config(model)

    user = get_user(email, model)
    if user do
      crypto.checkpw(password, Map.get(user, hashed_passwd)) && user
    else
      crypto.dummy_checkpw
    end
  end

  @doc """
  Loads a user by a given identity field value. Returns a nil on failure.

      get_user("rico@gmail.com")  #=> %User{...}
  """
  def get_user(email, model \\ nil) do
    %{repo: repo, model: model, identity_field: id} =
      Authsense.config(model)

    repo.get_by(model, [{id, email}])
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
  def generate_hashed_password(%Changeset{} = changeset, model \\ nil) do
    %{password_field: passwd, hashed_password_field: hashed_passwd,
      crypto: crypto} = Authsense.config(model)

    case get_change(changeset, passwd) do
      nil ->
        changeset
      password ->
        changeset
        |> put_change(hashed_passwd, crypto.hashpwsalt(password))
    end
  end

  # Adds errors to a changeset.
  # Used by `authenticate/2`.
  defp auth_failure(changeset_or_tuple, model \\ nil)
  defp auth_failure(%Changeset{} = changeset, model) do
    %{password_field: passwd, login_error: login_error} =
      Authsense.config(model)

    changeset
    |> validate_change(passwd, fn _, _ -> [{passwd, login_error}] end)
  end

  defp auth_failure(_opts, _), do: nil
end
