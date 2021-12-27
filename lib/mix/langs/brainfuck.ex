defmodule Mix.Tasks.Brainfuck do
  @moduledoc "Mix task for evaluating .bf-files or Brainfuck Code"
  use Mix.Task

  alias Esolix.Langs.Brainfuck

  @doc """
    Executes Brainfuck Code either by string or by file path.

    ## Examples

      ```sh
      mix template "Some hello world Brainfuck Code"
      Hello World

      mix template /path/to/brainfuck/hello_world_file
      Hello World
      ```
  """
  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)

        if File.exists?(Enum.at(args, 0)) do
          Brainfuck.execute_file(arg)
        else
          Brainfuck.execute(arg)
        end
    end
  end
end
