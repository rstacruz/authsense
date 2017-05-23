defmodule Authsense.Test.Repo do
  alias Authsense.Test.User

  def get(_model, 1) do
    valid_resource "rico@gmail.com", "foobar"
  end
  def get(_model, _id), do: nil

  def get_by(_model, email: "nobody@gmail.com"), do: nil
  def get_by(_model, email: "rico@gmail.com") do
    valid_resource "rico@gmail.com", "foobar"
  end

  def where(_model, extra_field: "unicorn") do
    valid_resource "rico@gmail.com", "foobar"
  end

  def where(_model, extra_field: extra_field), do: nil

  defp valid_resource(email, password) do
    %User{id: 1, email: email, hashed_password: crypto.hashpwsalt(password)}
  end

  defp crypto do
    Authsense.config.crypto
  end
end
