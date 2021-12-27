defmodule Mix.Tasks.Piet do
  @moduledoc "Mix task for evaluating Piet Code"
  use Mix.Task

  alias Esolix.Langs.Piet

  @spec run(list) :: :ok | [binary]
  @doc """
    Executes Piet Code.

    ## Examples

    ```sh
    mix template "Some hello world Piet Code"
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
          Piet.execute_file(arg)
        else
          Piet.execute(arg)
        end
    end
  end
end
