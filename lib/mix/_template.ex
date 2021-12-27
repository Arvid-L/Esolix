defmodule Mix.Tasks.Template do
  @moduledoc "Mix task for evaluating Template Code"
  use Mix.Task

  alias Esolix.Langs.Template

  @spec run(list) :: :ok | [binary]
  @doc """
    Executes Template Code.

    ## Examples

    ```sh
    mix template "Some hello world Template Code"
    Hello World

    mix template /path/to/template/hello_world_file
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
          Template.execute_file(arg)
        else
          Template.execute(arg)
        end
    end
  end
end
