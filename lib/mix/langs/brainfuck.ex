defmodule Mix.Tasks.Brainfuck do
  @moduledoc "Mix task for evaluating .bf-files or Brainfuck Code"
  use Mix.Task

  alias Esolix.Langs.Brainfuck

  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)

        if File.exists?(Enum.at(args, 0)) do
          Brainfuck.eval_file(arg)
        else
          Brainfuck.eval(arg)
        end
    end
  end
end
