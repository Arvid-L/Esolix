defmodule Esolix.Langs.Chicken do
  @moduledoc """
  Documentation for the Chicken Module
  """

  # Data Structure used:
  # alias Esolix.DataStructures.Tape


  # Custom Module Errors
  defmodule CustomModuleError do
    defexception [:message]

    def exception() do
      msg = "Something went wrong I think"
      %CustomModuleError{message: msg}
    end
  end


  @doc """
    Run Chicken Code

    ## Examples

      iex> Chicken.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, params \\ []) do
    validate_code(code)

    # Do something
  end

  @doc """
    Run Chicken Code from file

    ## Examples

      iex> Chicken.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    validate_file(file)
    |> extract_file_contents()
    |> eval(params)
  end

  defp validate_file(file) do
    # Do something
  end

  defp extract_file_contents(file) do
    File.read!(file)
  end

  defp validate_code(code) do
    graphemes = String.graphemes(code)
    # Do something
  end

end
