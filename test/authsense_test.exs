defmodule AuthsenseTest do
  use ExUnit.Case
  doctest Authsense

  test "config(nil)" do
    config = Authsense.config
    assert config.model == Authsense.Test.User
    assert config.repo == Authsense.Test.Repo
  end

  test "sets defaults" do
    config = Authsense.config
    assert config.identity_field == :email
  end

  test "accepts models" do
    config = Authsense.config(Authsense.Test.User)
    assert config.model == Authsense.Test.User
  end

  test "works even if config for model isn't set" do
    config = Authsense.config(Exunit)
    assert config.repo == nil
    assert config.model == Exunit
  end

  test "accepts lists" do
    config = Authsense.config(model: Authsense.Test.User, foo: :bar)
    assert config.model == Authsense.Test.User
    assert config.foo == :bar
  end

  @tag :pending
  test "put_current_user"

  @tag :pending
  test "fetch_current_user"

  @tag :pending
  test "config"
end
