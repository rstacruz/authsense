## [v0.3.0]
> Jun 27, 2016

- [#2] - Shows errors when multiple resources are configured (`MultipleResourcesException`). ([@victorsolis])
- [#2] - Shows errors in compile time when Authsense isn't configured (`UnconfiguredException`). ([@victorsolis])
- [#2] - General refactoring to improve configuration management. ([@victorsolis])

[v0.3.0]: https://github.com/rstacruz/authsense/compare/v0.2.0...v0.3.0
[#2]: https://github.com/rstacruz/authsense/issues/2

## [v0.2.0]
> Jun 25, 2016

Authsense's API has been significantly rewritten. It now uses `Mix.Config` for configuration.

```elixir
config :authsense,
  Myapp.User,
  repo: Myapp.Repo
```

Instead of `Auth.*`, the functions are now in `Authsense.Service` and `Authsense.Plug`.

```elixir
changeset
|> Authsense.Service.generate_hashed_password()

conn
|> Authsense.Plug.fetch_current_user()
```

The new Mix-based config now means the module-based configuration is now deprecated.

```elixir
# <DEPRECATED>
defmodule Myapp.Auth do
  use Authsense,
    model: Myapp.User,
    repo: Myapp.Repo
end
# </DEPRECATED>
```

Special thanks to [@victorsolis] for all the guidance that went into this release.

[@victorsolis]: https://github.com/victorsolis
[v0.2.0]: https://github.com/rstacruz/authsense/compare/v0.1.0...v0.2.0

## [v0.1.0]
> Jun 23, 2016

- Initial release.

[v0.1.0]: https://github.com/rstacruz/authsense/tree/v0.1.0
