defmodule Authsense.UnconfiguredException do
  @moduledoc """
  Raised when no configuration for `Authsense` is provided.
  """
  defexception [:message]

  def exception(_) do
    message = """
    Please configure Authsense.

        Example configuration:

          config :authsense, MyApp.User,
            repo: MyApp.Repo
    """
    %Authsense.UnconfiguredException{message: message}
  end
end

defmodule Authsense.MultipleResourcesException do
  @moduledoc """
  When a single resource is configured for `Authsense`, it will
  automatically use that resource for function calls that need
  it, such as `Authsense.Service.generate_hashed_password/2`.

  However, when multiple resources are configured, this exception
  will be raised for functions that require a resource module as
  `Authsense` will not be able to determine which resource to use
  for that call.

  This can be avoided by providing the correct resource module to
  be used, e.g.,

    `Authsense.Service.generate_hashed_password(changeset, User)`
  """
  defexception [:message]

  def exception(_) do
    resources =
      Application.get_all_env(:authsense)
      |> Enum.map(fn {resource, _} -> resource end)

    message = """
    Multiple resources are configured.

        Authsense cannot determine which resource module to use.
        Available resource modules: #{inspect resources}
    """
    %Authsense.MultipleResourcesException{message: message}
  end
end

defmodule Authsense.InvalidScopeException do
  @moduledoc """
  Raised when passed scope to `Authsense.Service.authenticate/2`,
  `Authsense.Service.authenticate_user/2`, and `Authsense.Service.get_user/2`
  is either a lambda that does not return an `Ecto.Query`,
  or is not convertible to `Ecto.Query`
  """

  defexception [:message]

  def exception(message) do
    message = """
    Passed scope is of invalid type

      #{message}
    """
    %Authsense.InvalidScopeException{message: message}
  end
end
