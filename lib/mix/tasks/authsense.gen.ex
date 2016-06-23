defmodule Mix.Tasks.Authsense.Gen do
  use Mix.Task

  @shortdoc "Eats chocolate"

  @moduledoc """
  I like turtles
  """

  @defaults %{
    model: "User",
    plural: "users",
    identity_field: :email,
    password_field: :password,
    hashed_password_field: :hashed_password
  }

  def run(args) do
    {opts, argv} = parse_args(args)

    {opts, argv}
    |> add_migration
    # |> add_controller -- AuthController
    # |> print_route_instructions
  end

  def add_migration({opts, _argv} = args) do
    Mix.Task.run "phoenix.gen.migration", [
      opts[:model], opts[:plural],
      "#{opts[:identity_field]}:string",
      "#{opts[:hashed_password_field]}:string"
    ]
    args
  end

  @doc """
  Parses arguments
  """
  def parse_args(args) do
    switches = [] #no_model: :boolean
    {opts, argv, _} = OptionParser.parse(args, switches: switches)
    opts = Enum.into(opts, @defaults)
    {opts, argv}
  end
end
