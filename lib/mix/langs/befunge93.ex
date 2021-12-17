defmodule Mix.Tasks.Befunge93 do
  @moduledoc "Mix task for evaluating Befunge93 Code"
  use Mix.Task

  alias Esolix.Langs.Befunge93

  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)

        if File.exists?(Enum.at(args, 0)) do
          Befunge93.eval_file(arg)
        else
          Befunge93.eval(arg)
        end
    end
  end
end
