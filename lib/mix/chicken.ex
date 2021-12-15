defmodule Mix.Tasks.Chicken do
  @moduledoc "Mix task for evaluating Chicken Code"
  use Mix.Task

  alias Esolix.Langs.Chicken

  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")
      _ ->
        arg = Enum.at(args, 0)
        if File.exists?(Enum.at(args, 0)) do
          Chicken.eval_file(arg)
        else
          Chicken.eval(arg)
        end
    end
  end

end
