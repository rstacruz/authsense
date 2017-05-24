defmodule Authsense.Test.Query do
  alias Authsense.Test.Repo

  def where(_model, extra_field: extra_field), do: Enum.filter(Repo.all(), &(&1.extra_field == extra_field))
end
