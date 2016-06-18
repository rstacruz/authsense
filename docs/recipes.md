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

Use `Auth.generate_hashed_password/2` for their changesets. This way, when
updating or creating users, any new `:password` fields will be hashed into
`:hashed_password`.

```elixir
def changeset(model, params \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> Auth.generate_hashed_password()
  |> validate_confirmation(:password, message: "password confirmation doesn't match")
  |> unique_constraint(:email)
end
```

## Login page

I typically like having an `AuthController` handle all auth-related actions.

```elixir
# web/router.ex
get "/login", AuthController, :login
post "/login", AuthController, :login_create
get "/logout", AuthController, :logout
```

`AuthController.login` gets you a form. Use a changeset here.

```elixir
# web/controllers/auth_controller.ex

def login(conn, params) do
  changeset = User.changeset(%User{})
  render(conn, "login.html", changeset: changeset)
end
```

`AuthController.login_create` logs someone in (creates a session) using `Auth.put_current_user/2`.

```elixir
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
```

`AuthController.logout` logs you out using `Auth.put_current_user/2`.

```elixir
def logout(conn, _params) do
  conn
  |> Auth.put_current_user(nil)
  |> put_flash(:info, "You've been logged out.")
  |> redirect(to: "/")
end
```

## Register/sign up

This is just a simple `create` action for users.

## Secure pages

To make certain pages, you can implement your own `ensure_authenticated` helper.

```elixir
defmodule Myapp.Auth do
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def ensure_authenticated(conn, _opts) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_flash(:error, "You have to be logged in to do that.")
      |> redirect(to: "/")
    end
  end
end
```

Use it as a plug after using `Auth`.

```elixir
defmodule Myapp.MyController do
  import Auth

  plug :fetch_current_user
  plug :ensure_authenticated
end
```

## Token-based authentication

You can implement your own version of `Auth.fetch_current_user/2` to
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

# add `import Auth` to your web/web.ex
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
