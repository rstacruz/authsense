defmodule Authsense.Test.Repo do
  alias Authsense.Test.User

  def get(_model, 1) do
    valid_resource "rico@gmail.com", "foobar"
  end
  def get(_model, _id), do: nil

  def get_by(query = %Ecto.Query{}, email: "rico@gmail.com") do
    [%Ecto.Query.QueryExpr{expr: expression}] = query.wheres
    { _, _, [ _, %Ecto.Query.Tagged{value: value} ] } = expression

    case value do
      "newbie" -> nil
      "unicorn" -> valid_resource "rico@gmail.com", "foobar"
    end
  end

  def get_by(_model, email: "rico@gmail.com"), do: valid_resource "rico@gmail.com", "foobar"
  def get_by(_model, _email), do: nil

  defp valid_resource(email, password) do
    %User{id: 1, email: email, hashed_password: crypto.hashpwsalt(password)}
  end

  defp crypto do
    Authsense.config.crypto
  end
end
