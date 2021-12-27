defmodule Mix.Tasks.Chicken do
  @moduledoc "Mix task for evaluating Chicken Code"
  use Mix.Task

  alias Esolix.Langs.Chicken

  @doc """
    Executes Chicken Code either by string or by file path.

    ## Examples

      ```sh
      mix template "Some hello world Chicken Code"
      Hello World

      mix template /path/to/chicken/hello_world_file
      Hello World
      ```
  """
  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)
        input = Enum.at(args, 1)

        if File.exists?(Enum.at(args, 0)) do
          Chicken.execute_file(arg, input: input)
        else
          Chicken.execute(arg, input: input)
        end
    end
  end
end
