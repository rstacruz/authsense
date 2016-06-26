defmodule Authsense.Test.Repo do
  def start_link do
    Agent.start_link fn -> [] end, name: :test_repo
  end

  def insert(%Ecto.Changeset{} = changeset) do
    insert changeset.changes
  end

  def insert(resource) do
    Agent.update :test_repo, fn state -> [resource|state] end
    resource
  end

  def get(_model, id) do
    Agent.get :test_repo, fn state ->
      Enum.find(state, &(&1.id == id))
    end
  end

  def get_by(_model, email: email) do
    Agent.get :test_repo, fn state ->
      Enum.find(state, &(&1.email == email))
    end
  end
end
