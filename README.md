# Authsense

> Sensible authentication helpers for Phoenix/Ecto

## Installation

Add authsense to your list of dependencies in `mix.exs`:

```elixir
def deps do
  #[{:authsense, "~> 0.0.1"}]
  [{:authsense, git: "https://github.com/rstacruz/authsense.git"}]
end
```

Ensure authsense is started before your application:

```elixir
def application do
  [applications: [:authsense]]
end
```

## Overview

Create a module:

```elixir
defmodule Myapp.Auth do
  use Authsense, %{
    repo: Myapp.Auth,
    model: Myapp.User
  }
end
```

You can then call some helpers for authentication:

```elixir
# For login actions
Auth.authenticate(changeset)  #=> {:ok, user} or {:error, changeset_with_errors}
Auth.authenticate({ "userid", "password" })  #=> %User{} | nil
```

```elixir
# For login/logout actions
conn |> Auth.set_current_user(user)  # login
conn |> Auth.set_current_user(nil)   # logout
```

```elixir
# For model changesets
changeset
|> Auth.generate_hashed_password()
```

```elixir
# For controllers
plug Auth
conn.assigns.current_user  #=> %User{} | nil
```

See hexdocs for more info.

## Thanks

**authsense** © 2016+, Rico Sta. Cruz. Released under the [MIT] License.<br>
Authored and maintained by Rico Sta. Cruz with help from contributors ([list][contributors]).

> [ricostacruz.com](http://ricostacruz.com) &nbsp;&middot;&nbsp;
> GitHub [@rstacruz](https://github.com/rstacruz) &nbsp;&middot;&nbsp;
> Twitter [@rstacruz](https://twitter.com/rstacruz)

[MIT]: http://mit-license.org/
[contributors]: http://github.com/rstacruz/authsense/contributors
