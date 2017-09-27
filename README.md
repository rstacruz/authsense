, Authsense

> Sensible authentication helpers for Phoenix/Ecto

[![Status](https://travis-ci.org/rstacruz/authsense.svg?branch=master)](https://travis-ci.org/rstacruz/authsense "See test builds")

## Installation

Add authsense to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:authsense, "~> 0.4.1"}]
end
```

## Overview

Please consult the [Authsense documentation](http://ricostacruz.com/authsense/) for full details.

Configure authsense:

```elixir
config :authsense, Myapp.User,
   repo: Myapp.Repo
```

You can then call some helpers for authentication:

```elixir
# For login actions
authenticate(changeset)  #=> {:ok, user} or {:error, changeset_with_errors}
authenticate({ "userid", "password" })  #=> %User{} | nil
```

```elixir
# For login/logout actions
conn |> put_current_user(user)  # login
conn |> put_current_user(nil)   # logout
```

```elixir
# For model changesets
changeset
|> generate_hashed_password()
```

```elixir
# For controllers
import Authsense.Plug
plug :fetch_current_user
conn.assigns.current_user  #=> %User{} | nil
```

Please consult the [Authsense documentation](http://ricostacruz.com/authsense/) detailed info.

## Thanks

**authsense** © 2016+, Rico Sta. Cruz. Released under the [MIT] License.<br>
Authored and maintained by Rico Sta. Cruz with help from contributors ([list][contributors]).

> [ricostacruz.com](http://ricostacruz.com) &nbsp;&middot;&nbsp;
> GitHub [@rstacruz](https://github.com/rstacruz) &nbsp;&middot;&nbsp;
> Twitter [@rstacruz](https://twitter.com/rstacruz)

[MIT]: http://mit-license.org/
[contributors]: http://github.com/rstacruz/authsense/contributors
