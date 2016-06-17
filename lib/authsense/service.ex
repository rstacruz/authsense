defmodule Authsense.Service do
  import Ecto.Changeset, only:
    [get_change: 2, put_change: 3, validate_change: 3]

  @doc """
  See `Authsense.authenticate/2`.
  """
  def authenticate(opts, changeset) do
    case authenticate_user(opts, changeset) do
      false -> {:error, auth_failure(opts, changeset)}
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
  def authenticate_user(opts, %Ecto.Changeset{} = changeset) do
    %{identity_field: id, password_field: passwd} = opts

    email = get_change(changeset, id)
    password = get_change(changeset, passwd)
    authenticate_user(opts, {email, password})
  end

  def authenticate_user(opts, {email, password}) do
    %{crypto: crypto, hashed_password_field: hashed_passwd} = opts

    user = load_user(opts, email)
    if user do
      crypto.checkpw(password, Map.get(user, hashed_passwd)) && user
    else
      crypto.dummy_checkpw
    end
  end

  @doc """
  See `Authsense.load_user/1`.
  """
  def load_user(opts, email) do
    %{repo: repo, model: model, identity_field: id} = opts

    repo.get_by(model, [{id, email}])
  end

  @doc """
  See `Authsense.generate_hashed_password/1`.
  """
  def generate_hashed_password(opts, changeset) do
    %{password_field: passwd, hashed_password_field: hashed_passwd,
      crypto: crypto} = opts

    case get_change(changeset, passwd) do
      nil ->
        changeset
      password ->
        changeset
        |> put_change(hashed_passwd, crypto.hashpwsalt(password))
    end
  end

  defp auth_failure(opts, %Ecto.Changeset{} = changeset) do
    %{password_field: passwd, login_error: login_error} = opts

    changeset
    |> validate_change(passwd, fn _, _ -> [{passwd, login_error}] end)
  end

  defp auth_failure(_opts, _), do: nil
end
