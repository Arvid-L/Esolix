defmodule Mix.Tasks.Template do
  @moduledoc "Mix task for evaluating Template Code"
  use Mix.Task

  alias Esolix.Langs.Template

  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)

        if File.exists?(Enum.at(args, 0)) do
          Template.execute_file(arg)
        else
          Template.execute(arg)
        end
    end
  end
end
