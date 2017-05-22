defmodule Authsense.Test.Repo do
  alias Authsense.Test.User

  def get(_model, id), do: Enum.find(mock_data(), &(&1.id == id))
  def get_by(_model, [email: email, extra_field: extra_field]), do: Enum.find(mock_data, &(&1.email == email && &1.extra_field == extra_field))
  def get_by(_model, [email: email]), do: Enum.find(mock_data(), &(&1.email == email))
  defp mock_data do
    [
      %{
        id: 1,
        email: "rico@gmail.com",
        hashed_password: crypto.hashpwsalt("foobar"),
        extra_field: "unicorn"
      },
      %{
        id: 2,
        email: "jekku@gmail.com",
        hashed_password: crypto.hashpwsalt("barfoo"),
        extra_field: "newbie"
      }
    ]
  end

  defp crypto do
    Authsense.config.crypto
  end
end
