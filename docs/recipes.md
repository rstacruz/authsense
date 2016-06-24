# Recipes

## User model

Aside from the obvious `:email` and `:hashed_password`, you should have
`:password` and `:password_confirmation` _virtual_ fields for users. This
allows you to have your forms ask users for their `:password`.

```elixir
schema "users" do
  field :email, :string
  field :hashed_password, :string
  field :password, :string, virtual: true
  field :password_confirmation, :string, virtual: true

  timestamps
end
```

Use `Authsense.Serviec.generate_hashed_password/2` for their changesets. This
way, when updating or creating users, any new `:password` fields will be hashed
into `:hashed_password`.

```elixir
# ecto 2.0
def changeset(model, params \\ []) do
  model
  |> cast(params, [:email, :password, :password_confirmation])
  |> Authsense.Service.generate_hashed_password()
  |> validate_confirmation(:password, message: "password confirmation doesn't match")
  |> unique_constraint(:email)
end
```

## Login page

I typically like having an `SessionController` handle logins and logouts.

```elixir
# web/router.ex
get "/login",  SessionController, :new
post "/login", SessionController, :create
get "/logout", SessionController, :delete
```

`SessionController.new` gets you a form. Use a changeset here.

```elixir
# web/controllers/session_controller.ex

def new(conn, params) do
  changeset = User.changeset(%User{})
  render(conn, "new.html", changeset: changeset)
end
```

`SessionController.create` logs someone in (creates a session) using `Authsense.Plug.put_current_user/2`.

```elixir
def create(conn, %{"user" => user_params}) do
  changeset = User.changeset(%User{}, user_params)

  case Auth.authenticate(changeset) do
    {:ok, user} ->
      conn
      |> Auth.put_current_user(user)
      |> put_flash(:info, "Welcome.")
      |> redirect(to: "/")
    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end
```

`sessionController.delete` logs you out using `Authsense.Plug.put_current_user/2`.

```elixir
def logout(conn, _params) do
  conn
  |> Authsense.Plug.put_current_user(nil)
  |> put_flash(:info, "You've been logged out.")
  |> redirect(to: "/")
end
```

## Register/sign up

This is just a simple `create` action for users.

## Secure pages

_(To be documented)_

## Token-based authentication

You can implement your own version of `Authsense.Plug.fetch_current_user/2` to
authenticate based on something else other than passwords.

```elixir
def authenticate_by_token(conn, _opts \\ []) do
  token = conn.params.token
  case Repo.get_by(User, api_token: token) do
    user ->
      assign(conn, :current_user, user)
    _ ->
      conn
  end
end
```

```elixir
# web/router.ex
pipeline :api do
  plug :authenticate_by_token
end
```

## Forgot your password

You'll need to create 4 actions: one for the "forgot your password" page, one
for the "reset your password" page, and one submission action for each of those.

You'll also need a `:perishable_token` in your User model.

### GET /forgot_password

   - Show the "enter your email" form.

### POST /forgot_password

  - Update the user's perishable token.

        user
        |> change(:perishable_token, Ecto.UUID.generate)
        |> Repo.update()

  - Send an email to the user with a link to `/update_password?token=...`.

### GET /update_password?token=...

  - Find the user with the given token.

        Repo.get_by(User, perishable_token: token)

  - Show the "enter your new password" form.

### POST /update_password?token=...

  - Find the user with the given token.
  - Update their password and clear their perishable token.

        user
        |> User.changeset(user_params)
        |> change(:perishable_token, nil)
        |> Repo.update()
