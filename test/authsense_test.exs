defmodule AuthsenseTest do
  use ExUnit.Case, async: true
  doctest Authsense

  setup do
    Application.delete_env :authsense, :included_applications

    on_exit fn ->
      Application.delete_env :authsense, Admin
    end

    :ok
  end

  test "config(nil)" do
    config = Authsense.config
    assert config.model == Authsense.Test.User
    assert config.repo == Authsense.Test.Repo
  end

  test "sets defaults" do
    config = Authsense.config
    assert config.identity_field == :email
  end

  test "overrides defaults" do
    Application.put_env :authsense, Admin,
      password_field: :custom_field
    config = Authsense.config(Admin)
    assert config.password_field == :custom_field
  end

  test "accepts models" do
    config = Authsense.config(AnotherModule)
    assert config.model == AnotherModule
    assert config.password_field == :password
  end

  test "works even if config for model isn't set" do
    config = Authsense.config(Exunit)
    assert config.repo == nil
    assert config.model == Exunit
  end

  test "accepts lists" do
    config = Authsense.config(model: AnotherModule, foo: :bar)
    assert config.model == AnotherModule
    assert config.foo == :bar
  end

  # test "accepts empty lists" do
  #   config = Authsense.config([])
  #   assert config.model == Authsense.Test.User
  # end
end
