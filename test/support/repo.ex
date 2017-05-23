defmodule Authsense.Test.Repo do
  alias Authsense.Test.User

  def get(_model, 1) do
    valid_resource "rico@gmail.com", "foobar"
  end
  def get(_model, _id), do: nil

  def get_by(model, email: email), do: Enum.find(model || mock_data(), &(&1.email == email))

  def where(_model, extra_field: extra_field), do: Enum.filter(mock_data(), &(&1.extra_field == extra_field))

  defp mock_data do
    [
      %User{id: 1, email: "rico@gmail.com", hashed_password: crypto.hashpwsalt("foobar"), extra_field: "unicorn"},
      %User{id: 2, email: "jekku@gmail.com", hashed_password: crypto.hashpwsalt("foobar"), extra_field: "newbie"}
    ]
  end

  defp valid_resource(email, password) do
    %User{id: 1, email: email, hashed_password: crypto.hashpwsalt(password)}
  end

  defp crypto do
    Authsense.config.crypto
  end
end
