defmodule Mix.Tasks.Befunge93 do
  @moduledoc "Mix task for evaluating Befunge93 Code"
  use Mix.Task

  alias Esolix.Langs.Befunge93

  @doc """
    Executes Befunge93 Code either by string or by file path.

    ## Examples

    ```sh
    mix template "Some hello world Befunge93 Code"
    Hello World

    mix template /path/to/befunge93/hello_world_file
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
          Befunge93.execute_file(arg)
        else
          Befunge93.execute(arg)
        end
    end
  end
end
