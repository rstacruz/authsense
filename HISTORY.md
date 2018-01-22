## [v1.0.0]
> Jan 22, 2018

Thanks [@jekku]!

- [#7] - Update to Ecto 2.2 (from 1.1).
- [#7] - Update to Elixir 1.5 (from 1.2).
- [#7] - Update to Comeonin 4.0 (from 2.4).

[v1.0.0]: https://github.com/rstacruz/authsense/compare/v0.4.1...v1.0.0
[#7]: https://github.com/rstacruz/authsense/issues/7
[@jekku]: https://github.com/jekku

## [v0.4.1]
> Sep 27, 2017

- Restrict versions to old Ecto and Comeonin versions for now :(

[v0.4.1]: https://github.com/rstacruz/authsense/compare/v0.4.0...v0.4.1

## [v0.4.0]
> Sep 27, 2017

- [#5] - Allow passing of scopes. (@jekku)

[v0.4.0]: https://github.com/rstacruz/authsense/compare/v0.3.0...v0.4.0
[#5]: https://github.com/rstacruz/authsense/issues/5
[@jekku]: https://github.com/jekku

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
