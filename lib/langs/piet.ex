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

  defmodule Codel do
    @moduledoc false
    defstruct [:color, :hue]
  end

  @colors %{
    white: {255, 255, 255},
    black: {0, 0, 0},
    light_red: {255, 192, 192},
    red: {255, 0, 0},
    dark_red: {192, 0, 0},
    light_yellow: {255, 255, 192},
    yellow: {255, 255, 0},
    dark_yellow: {192, 192, 0},
    light_green: {192, 255, 192},
    green: {0, 255, 0},
    dark_green: {0, 192, 0},
    light_cyan: {192, 255, 255},
    cyan: {0, 255, 255},
    dark_cyan: {0, 192, 192},
    light_blue: {192, 192, 255},
    blue: {0, 0, 255},
    dark_blue: {0, 0, 192},
    light_magenta: {255, 192, 255},
    magenta: {255, 0, 255},
    dark_magenta: {192, 0, 192}
  }

  @spec eval(pixels(), keyword()) :: String.t()
  @doc """
    Run Piet Code (represented as pixels, represented as RGB values) and returns the IO output as a string.

    ## Examples

      iex> Piet.eval("some hello world code")
      "Hello World!"

  """
  def eval(pixels, params \\ []) do
    capture_io(fn ->
      execute(pixels)
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
    Run Piet Code (represented as pixels, represented as RGB values).

    ## Examples

      iex> Piet.execute("some hello world code")
      "Hello World!"
      :ok
  """
  def execute(pixels, _params \\ []) do
    pixels
    |> pixels_to_codels()
    |> IO.inspect()

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

  defp pixels_to_codels(pixels) do
    pixels
    |> Enum.map(fn line ->
      line
      |> Enum.map(fn pixel ->
        pixel_to_codel(pixel)
      end)
    end)
  end

  defp pixel_to_codel(pixel) do
    @colors
    |> Enum.find(fn {_color_name, color_value} -> color_value == pixel end)
    |> case do
      nil ->
        # Treat other colors as white
        %Codel{color: :white, hue: :none}

      {color_name, _color_value} ->
        %Codel{color: color_name, hue: get_hue_by_color_name(color_name)}
    end
  end

  defp get_hue_by_color_name(color_name) do
    Atom.to_string(color_name)
    |> String.split("_")
    |> Enum.at(0)
    |> case do
      "white" ->
        :none

      "black" ->
        :none

      "light" ->
        :light

      "dark" ->
        :dark

      _ ->
        :normal
    end
  end
end
