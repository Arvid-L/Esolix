defmodule Esolix.Langs.Piet do
  @moduledoc """
  Documentation for the Piet Module
  """

  # Data Structure used
  alias Esolix.DataStructures.Stack

  import ExUnit.CaptureIO

  @typedoc """
  List containing lines of pixels.
  """
  @type pixels :: list(pixel_line())

  @typedoc """
  List of pixels, represented as RGB values.
  """
  @type pixel_line :: list(pixel_rgb)

  @typedoc """
  Tuple, representing a Pixel by its RGB values: {Red, Green, Blue}
  """
  @type pixel_rgb :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}

  # # Custom Module Errors
  # defmodule CustomModuleError do
  #   @moduledoc false

  #   defexception [:message]

  #   def exception() do
  #     msg = "Something went wrong I think"
  #     %CustomModuleError{message: msg}

  #   end
  # end

  @spec eval(pixels(), keyword()) :: String.t()
  @doc """
    Runs Piet Code (List of Codels) and returns the IO output as a string.

    ## Examples

      iex> Piet.eval("some hello world code")
      "Hello World!"

  """
  def eval(codels, params \\ []) do
    capture_io(fn ->
      execute(codels)
    end)
  end

  @spec eval_file(String.t(), keyword()) :: String.t()
  @doc """
    Runs Piet Code from a .png file and returns the IO output as a string

    ## Examples

      iex> Piet.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    validate_file(file)
    |> extract_pixels()
    |> eval(params)
  end

  @spec execute(pixels(), keyword()) :: :ok
  @doc """
    Run Piet Code (Codels).

    ## Examples

      iex> Piet.execute("some hello world code")
      "Hello World!"
      :ok
  """
  def execute(codels, _params \\ []) do
    IO.inspect(codels)

    :ok
  end

  @spec execute_file(String.t(), keyword()) :: :ok
  @doc """
    Run Piet Code from a .png file.

    ## Examples

      iex> Piet.eval_file("path/to/some/hello_world.png")
      "Hello World!"
      :ok

  """
  def execute_file(file, params \\ []) do
    validate_file(file)
    |> extract_pixels()
    |> execute(params)

    :ok
  end

  defp validate_file(file) do
    case {File.exists?(file), Path.extname(file) |> String.downcase()} do
      {false, _} ->
        raise "File #{file} does not exist"

      {true, ".png"} ->
        file

      _ ->
        raise "File #{file} is not a png"
    end
  end

  defp extract_pixels(file) do
    case Imagineer.load(file) do
      {:ok, image_data} ->
        IO.inspect(image_data)
        Map.get(image_data, :pixels)

      _ ->
        raise "Error while extracting PNG image data"
    end
  end
end
