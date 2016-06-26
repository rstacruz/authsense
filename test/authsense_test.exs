defmodule AuthsenseTest do
  use ExUnit.Case
  doctest Authsense

  setup do
    Application.delete_env :authsense, :included_applications

    on_exit fn ->
      Application.delete_env :authsense, Admin
      Application.put_env :authsense, Authsense.Test.User,
        repo: Authsense.Test.Repo
    end

    :ok
  end

  test "config with no resource configured" do
    Application.delete_env :authsense, Authsense.Test.User

    assert Authsense.config(Admin).model == Admin
    assert_raise Authsense.UnconfiguredException, fn ->
      Authsense.config
    end
  end

  test "config with only one resource configured" do
    assert Authsense.config.model == Authsense.Test.User
    assert Authsense.config.repo == Authsense.Test.Repo
  end

  test "config with multiple resources configured" do
    Application.put_env :authsense, Admin, password_field: :custom_field

    assert Authsense.config(Admin).model == Admin
    assert_raise Authsense.MultipleResourcesException, fn ->
      Authsense.config
    end
  end

  test "sets defaults" do
    assert Authsense.config.identity_field == :email
  end

  test "overrides defaults" do
    Application.put_env :authsense, Admin, password_field: :custom_field

    assert %{
      model: Admin,
      password_field: :custom_field,
      repo: nil,
      identity_field: :email
    } = Authsense.config(Admin)
  end

  test "works even if config for model isn't set" do
    assert %{
      model: NotConfigured,
      repo: nil,
      identity_field: :email
    } = Authsense.config(NotConfigured)
  end

  test "accepts lists" do
    assert %{
      model: NotConfigured,
      foo: :bar,
      identity_field: :email
    } = Authsense.config(model: NotConfigured, foo: :bar)
  end

  test "accepts empty lists" do
    assert Authsense.config([]).model == Authsense.Test.User
  end
end
