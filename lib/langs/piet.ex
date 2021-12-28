defmodule Esolix.Langs.Piet do
  @moduledoc """
  Documentation for the Piet Module
  """

  # Data Structure used:
  # alias Esolix.DataStructures.Tape

  import ExUnit.CaptureIO

  # Custom Module Errors
  defmodule CustomModuleError do
    @moduledoc false

    defexception [:message]

    def exception() do
      msg = "Something went wrong I think"
      %CustomModuleError{message: msg}
    end
  end

  @spec eval(String.t(), keyword()) :: String.t()
  @doc """
    Runs Piet Code and returns the IO output as a string.

    ## Examples

      iex> Piet.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, params \\ []) do
    capture_io(fn ->
      execute(code)
    end)
  end

  @spec eval_file(String.t(), keyword()) :: String.t()
  @doc """
    Runs Piet Code from file and returns the IO output as a string.

    ## Examples

      iex> Piet.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    validate_file(file)
    |> extract_file_contents()
    |> eval(params)
  end

  @spec execute(String.t(), keyword()) :: :ok
  @doc """
    Run Piet Code.

    ## Examples

      iex> Piet.execute("some hello world code")
      "Hello World!"
      :ok
  """
  def execute(code, params \\ []) do
    validate_code(code)

    # Do something
  end

  @spec execute_file(String.t(), keyword()) :: :ok
  @doc """
    Run Piet Code from file.

    ## Examples

      iex> Piet.eval_file("path/to/some/hello_world.file")
      "Hello World!"
      :ok

  """
  def execute_file(file, params \\ []) do
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
