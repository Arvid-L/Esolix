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

  defmodule PietExecutor do
    @moduledoc false
    defstruct [:codels, :stack, :dp, :cc, :codel_coord, :codel_current, :locked_in_attempts]
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
  @hue_cycle [:light, :normal, :dark]
  @color_cycle [:red, :yellow, :green, :cyan, :blue, :magenta]

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
    codels = pixels_to_codels(pixels)

    piet_exec = %PietExecutor{
      codels: codels,
      stack: Stack.init(),
      codel_coord: {0, 0},
      codel_current: Enum.at(codels, 0) |> Enum.at(0),
      dp: :right,
      cc: :left,
      locked_in_attempts: 0
    }

    execute_step(piet_exec)

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

  defp execute_step(
         %PietExecutor{
           codels: codels,
           codel_coord: codel_coord,
           codel_current: codel_current,
           dp: dp,
           cc: cc,
           locked_in_attempts: locked_in_attempts
         } = piet_exec
       ) do
    next_coords = next_coordinates(codel_coord, dp)
    next_codel = codel_at(codels, next_coords)

    cond do
      # Case 1: Next Codel identical, carry on
      next_codel == codel_current ->
        execute_step(%{piet_exec | codel_coord: next_coords, codel_current: next_codel})

      # Case 2: Next Codel is black or edge: toggle cc or dp and try again
      next_codel in [nil, %Codel{color: :black, hue: :none}] ->
        execute_step(%{
          piet_exec
          | cc: maybe_toggle_cc(cc, locked_in_attempts),
            dp: maybe_toggle_dp(dp, locked_in_attempts),
            locked_in_attempts: locked_in_attempts + 1
        })

      # Case 3: Max number of locked in attempts reached, terminate program
      locked_in_attempts == 8 ->
        piet_exec

      # Case 4: Next Codel is white:
      next_codel == %Codel{color: :white, hue: :none} ->
        IO.puts("white")

      # slide across?
      # Case 5: Next Codel is another valid color, parse command
      true ->
        color_difference = color_difference(codel_current, next_codel)
        hue_difference = hue_difference(codel_current, next_codel)

        command = get_command(color_difference, hue_difference)
    end
  end

  defp get_command(color_difference, hue_difference) do
    case {color_difference, hue_difference} do
      {0, 0} ->
        :error

      {0, 1} ->
        :push

      {0, 2} ->
        :pop

      {1, 0} ->
        :add

      {1, 1} ->
        :sub

      {1, 2} ->
        :mul

      {2, 0} ->
        :div

      {2, 1} ->
        :mod

      {2, 2} ->
        :not

      {3, 0} ->
        :greater

      {3, 1} ->
        :pointer

      {3, 2} ->
        :switch

      {4, 0} ->
        :duplicate

      {4, 1} ->
        :roll

      {4, 2} ->
        :in_num

      {5, 0} ->
        :in_char

      {5, 1} ->
        :out_num

      {5, 2} ->
        :out_char
    end
  end

  defp maybe_toggle_cc(cc, locked_in_attempts) do
    case {cc, rem(locked_in_attempts, 2)} do
      {:left, 0} ->
        :right

      {:right, 0} ->
        :left

      {cc, 1} ->
        cc

      _ ->
        cc
    end
  end

  defp maybe_toggle_dp(dp, locked_in_attempts) do
    case {dp, rem(locked_in_attempts, 2)} do
      {:up, 1} ->
        :right

      {:right, 1} ->
        :down

      {:down, 1} ->
        :left

      {:left, 1} ->
        :up

      {dp, 0} ->
        dp

      _ ->
        dp
    end
  end

  defp codel_at(codels, {x, y}) do
    if -1 in [x, y] do
      nil
    else
      line = Enum.at(codels, y)
      if line, do: Enum.at(line, x), else: nil
    end
  end

  defp next_coordinates({x, y}, direction) do
    case direction do
      :right ->
        {x + 1, y}

      :up ->
        {x, y - 1}

      :left ->
        {x - 1, y}

      :down ->
        {x, y + 1}

      direction ->
        raise "Invalid direction: #{direction}"
    end
  end

  defp out_of_bounds?({x, y}, codels) do
    codel_at(codels, {x, y}) == nil
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

  defp hue_difference(%Codel{hue: hue_1}, %Codel{hue: hue_2}), do: hue_difference(hue_1, hue_2)

  defp hue_difference(hue_1, hue_2) do
    if :none in [hue_1, hue_2] do
      :error
    else
      Integer.mod(
        hue_index(hue_2) - hue_index(hue_1),
        length(@hue_cycle)
      )
    end
  end

  defp color_difference(%Codel{color: color_1}, %Codel{color: color_2}),
    do: color_difference(color_1, color_2)

  defp color_difference(color_1, color_2) do
    if Enum.any?([color_1, color_2], &(&1 in [:black, :white])) do
      :error
    else
      Integer.mod(
        color_index(color_2) - color_index(color_1),
        length(@color_cycle)
      )
    end
  end

  defp color_index(:red), do: 0
  defp color_index(:yellow), do: 1
  defp color_index(:green), do: 2
  defp color_index(:cyan), do: 3
  defp color_index(:blue), do: 4
  defp color_index(:magenta), do: 5
  defp color_index(_other), do: :none

  defp hue_index(:light), do: 0
  defp hue_index(:normal), do: 1
  defp hue_index(:dark), do: 2
  defp hue_index(_other), do: :none
end
