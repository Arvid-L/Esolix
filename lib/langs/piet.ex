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
           stack: stack,
           codels: codels,
           codel_coord: codel_coord,
           codel_current: codel_current,
           dp: dp,
           cc: cc,
           locked_in_attempts: locked_in_attempts
         } = piet_exec
       ) do
    next_coords = next_coordinates(codels, codel_coord, dp, cc)
    next_codel = codel_at(codels, next_coords)

    # debug(piet_exec, next_coords, next_codel, block_size(codels, codel_coord))

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

        piet_exec = execute_command(piet_exec, {color_difference, hue_difference})

        execute_step(%{
          piet_exec
          | codel_coord: next_coords,
            codel_current: next_codel,
            locked_in_attempts: 0
        })
    end
  end

  defp execute_command(
         %PietExecutor{
           stack: stack,
           codels: codels,
           codel_coord: codel_coord,
           codel_current: codel_current,
           dp: dp,
           cc: cc,
           locked_in_attempts: locked_in_attempts
         } = piet_exec,
         {color_difference, hue_difference}
       ) do
    # debug({color_difference, hue_difference})

    case {color_difference, hue_difference} do
      # Push
      {0, 1} ->
        stack = Stack.push(stack, block_size(codels, codel_coord))

        %{piet_exec | stack: stack}

      # Pop
      {0, 2} ->
        {_, stack} = Stack.pop(stack)

        %{piet_exec | stack: stack}

      # Add
      {1, 0} ->
        %{piet_exec | stack: Stack.add(stack)}

      # Sub
      {1, 1} ->
        %{piet_exec | stack: Stack.sub(stack, order: :reverse)}

      # Mul
      {1, 2} ->
        %{piet_exec | stack: Stack.mul(stack)}

      # Div
      {2, 0} ->
        %{piet_exec | stack: Stack.div(stack, order: :reverse)}

      # Mod
      {2, 1} ->
        %{piet_exec | stack: Stack.apply(stack, &Integer.mod/2, order: :reverse)}

      # Not
      {2, 2} ->
        %{piet_exec | stack: Stack.logical_not(stack, order: :reverse)}

      # Greater than
      {3, 0} ->
        %{piet_exec | stack: Stack.greater_than(stack)}

      # Rotate Direction Pointer
      {3, 1} ->
        {rotations, stack} = Stack.pop(stack)
        dp = rotate_dp(dp, rotations)

        %{piet_exec | stack: stack, dp: dp}

      # Toggle Codel Chooser
      {3, 2} ->
        {toggles, stack} = Stack.pop(stack)
        cc = toggle_cc(dp, toggles)

        %{piet_exec | stack: stack, cc: cc}

      # Duplicate
      {4, 0} ->
        %{piet_exec | stack: Stack.duplicate(stack)}

      # Roll
      {4, 1} ->
        {rolls, stack} = Stack.pop(stack)
        {depth, stack} = Stack.pop(stack)
        {elements_to_roll, stack} = Stack.popn(stack, depth)

        stack = Stack.push(stack, roll(elements_to_roll, rolls) |> Enum.reverse())

        %{piet_exec | stack: stack}

      # Input Number
      {4, 2} ->
        input = IO.gets("") |> String.trim() |> String.to_integer()

        %{piet_exec | stack: Stack.push(stack, input)}

      # Input Char
      {5, 0} ->
        input = IO.gets("") |> String.to_charlist() |> Enum.at(0)

        %{piet_exec | stack: Stack.push(stack, input)}

      # Output Number
      {5, 1} ->
        {output, stack} = Stack.pop(stack)
        IO.write(output)

        %{piet_exec | stack: stack}

      # Output Char
      {5, 2} ->
        {output, stack} = Stack.pop(stack)
        IO.write([output])

        %{piet_exec | stack: stack}

      other ->
        raise "Error, invalid command: #{other}"
    end
  end

  defp maybe_toggle_cc(cc, locked_in_attempts) do
    if rem(locked_in_attempts, 2) == 0 do
      toggle_cc(cc)
    else
      cc
    end
  end

  defp toggle_cc(cc, toggles \\ 1) do
    case {cc, rem(toggles, 2)} do
      {:left, 1} ->
        :right

      {:right, 1} ->
        :left

      _ ->
        cc
    end
  end

  defp maybe_toggle_dp(dp, locked_in_attempts) do
    if rem(locked_in_attempts, 2) == 1 do
      rotate_dp(dp, 1)
    else
      dp
    end
  end

  defp rotate_dp(dp, rotations) do
    direction = if rotations > 0, do: :clockwise, else: :counterclockwise
    rotations = abs(rotations)

    dp_cycle =
      case direction do
        :clockwise ->
          [:left, :up, :right, :down]

        :counterclockwise ->
          [:left, :down, :right, :up]
      end

    current = Enum.find_index(dp_cycle, &(&1 == dp))
    next = Integer.mod(current + rotations, 4)

    Enum.at(dp_cycle, next)
  end

  defp roll(elements, 0), do: elements

  defp roll(elements, rolls) when rolls < 0 do
    elements = Enum.reverse(elements)
    rolls = -rolls

    Enum.reduce(1..rolls, elements, fn _elem, acc ->
      [head | tail] = acc
      tail ++ [head]
    end)
    |> Enum.reverse()
  end

  defp roll(elements, rolls) do
    Enum.reduce(1..rolls, elements, fn _elem, acc ->
      [head | tail] = acc
      tail ++ [head]
    end)
  end

  defp codel_at(codels, {x, y}) do
    if -1 in [x, y] do
      nil
    else
      line = Enum.at(codels, y)
      if line, do: Enum.at(line, x), else: nil
    end
  end

  defp next_coordinates(codels, {x, y}, dp, cc) do
    color_block(codels, {x, y})
    |> furthest_dp(dp)
    |> furthest_cc(dp, cc)
    |> Enum.at(0)
    |> neighbor_coordinate(dp)
  end

  defp furthest_dp(coords, dp) do
    max_function =
      case dp do
        :left ->
          fn {x, _y} -> -x end

        :up ->
          fn {_x, y} -> -y end

        :right ->
          fn {x, _y} -> x end

        :down ->
          fn {_x, y} -> y end

        _ ->
          raise "Invalid direction pointer value"
      end

    {max_x, max_y} = Enum.max_by(coords, max_function)

    filter_function =
      cond do
        dp in [:left, :right] ->
          fn {x, _y} -> x == max_x end

        dp in [:up, :down] ->
          fn {_x, y} -> y == max_y end
      end

    Enum.filter(coords, filter_function)
  end

  defp furthest_cc(coords, dp, cc) do
    # Since the Codel Chooser direction is relative to the absolute Direction Pointer direction, we must translate it into an absoulte direction
    # This is achieved by rotating the Direction Pointer once into the direction of the Codel Chooser

    cc_absolute =
      case cc do
        :left ->
          rotate_dp(dp, -1)

        :right ->
          rotate_dp(dp, 1)
      end

    # Now we can just run furthest_dp again, using the already filtered coordinates and the absolute Codel Chooser direction instead of the Direction Pointer
    furthest_dp(coords, cc_absolute)
  end

  defp neighbor_coordinate({x, y}, dp) do
    case dp do
      :left ->
        left({x, y})

      :right ->
        right({x, y})

      :up ->
        up({x, y})

      :down ->
        down({x, y})
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
        IO.inspect(image_data, limit: :infinity)
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

      {hue_and_color, _color_value} ->
        %Codel{color: get_color(hue_and_color), hue: get_hue(hue_and_color)}
    end
  end

  defp get_hue(hue_and_color) do
    Atom.to_string(hue_and_color)
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

  defp get_color(hue_and_color) do
    Atom.to_string(hue_and_color) |> String.split("_") |> List.last() |> String.to_atom()
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

  def color_block(codels, {_x, _y} = coords) do
    get_all_identical_neighbors(codels, %{unchecked: [coords], checked: []})
  end

  defp block_size(codels, {_x, _y} = coords) do
    get_all_identical_neighbors(codels, %{unchecked: [coords], checked: []})
    |> length()
  end

  defp get_all_identical_neighbors(
         codels,
         %{unchecked: unchecked_coords, checked: checked_coords}
       ) do
    unchecked_coords_neighbors =
      unchecked_coords
      |> Enum.map(fn coords ->
        get_identical_neighbors(codels, coords)
      end)
      |> List.flatten()
      |> Enum.uniq()

    checked_coords_updated = Enum.uniq(checked_coords ++ unchecked_coords)

    if Enum.sort(checked_coords_updated) == Enum.sort(checked_coords) do
      # No new neighbors found, end search
      checked_coords
    else
      # Check neighbors of the newfound unchecked neighbors
      get_all_identical_neighbors(codels, %{
        unchecked: unchecked_coords_neighbors,
        checked: checked_coords_updated
      })
    end
  end

  defp get_identical_neighbors(codels, {_x, _y} = coords) do
    curr_codel = codel_at(codels, coords)
    up = if codel_at(codels, up(coords)) == curr_codel, do: up(coords)
    left = if codel_at(codels, left(coords)) == curr_codel, do: left(coords)
    right = if codel_at(codels, right(coords)) == curr_codel, do: right(coords)
    down = if codel_at(codels, down(coords)) == curr_codel, do: down(coords)

    Enum.filter([up, left, right, down], & &1)
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

  defp up({x, y}), do: {x, y - 1}
  defp right({x, y}), do: {x + 1, y}
  defp down({x, y}), do: {x, y + 1}
  defp left({x, y}), do: {x - 1, y}

  defp debug({c_dif, h_dif}) do
    output =
      case {c_dif, h_dif} do
        {0, 1} -> "push"
        {0, 2} -> "pop"
        {1, 0} -> "add"
        {1, 1} -> "sub"
        {1, 2} -> "mul"
        {2, 0} -> "div"
        {2, 1} -> "mod"
        {2, 2} -> "not"
        {3, 0} -> "greater"
        {3, 1} -> "pointer"
        {3, 2} -> "switch"
        {4, 0} -> "duplicate"
        {4, 1} -> "roll"
        {4, 2} -> "in number"
        {5, 0} -> "in char"
        {5, 1} -> "out number"
        {5, 2} -> "out char"
        _ -> ""
      end

    if output != "" do
      IO.puts("\n\n COMMAND: #{String.upcase(output)}")
    end
  end

  defp debug(
         %PietExecutor{
           stack: stack,
           #  codels: codels,
           codel_coord: {x, y},
           codel_current: codel_current,
           dp: dp,
           cc: cc,
           locked_in_attempts: locked_in_attempts
         },
         next_coords,
         next_codel,
         block_size
       ) do
    IO.gets("\n\nNext Step?")

    IO.inspect(binding())
  end
end
