defmodule Authsense.Service do
  import Ecto.Changeset, only:
    [get_change: 2, put_change: 3, validate_change: 3]

  @doc """
  See `Authsense.authenticate/2`.
  """
  def authenticate(credentials, %{} = opts) do
    case authenticate_user(credentials, opts) do
      false -> {:error, auth_failure(credentials, opts)}
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
  def authenticate_user(
    %Ecto.Changeset{} = changeset,
    %{identity_field: id, password_field: passwd} = opts)
  do
    email = get_change(changeset, id)
    password = get_change(changeset, passwd)
    authenticate_user({email, password}, opts)
  end

  def authenticate_user(
    {email, password},
    %{crypto: crypto, hashed_password_field: hashed_passwd} = opts)
  do
    user = get_user(email, opts)
    if user do
      crypto.checkpw(password, Map.get(user, hashed_passwd)) && user
    else
      crypto.dummy_checkpw
    end
  end

  @doc """
  See `Authsense.get_user/1`.
  """
  def get_user(email, %{repo: repo, model: model, identity_field: id}) do
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
  def generate_hashed_password(%Ecto.Changeset{} = changeset) do
    %{password_field: passwd, hashed_password_field: hashed_passwd,
      crypto: crypto} = Authsense.config
    case get_change(changeset, passwd) do
      nil ->
        changeset
      password ->
        changeset
        |> put_change(hashed_passwd, crypto.hashpwsalt(password))
    end
  end

  defp auth_failure(
    %Ecto.Changeset{} = changeset,
    %{password_field: passwd, login_error: login_error})
  do
    changeset
    |> validate_change(passwd, fn _, _ -> [{passwd, login_error}] end)
  end

  defp auth_failure(_opts, _), do: nil
end
