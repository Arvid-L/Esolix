defmodule Esolix.Langs.Befunge93 do
  @moduledoc """
  Documentation for the Befunge93 Module
  """

  # +	Addition: Pop two values a and b, then push the result of a+b
  # -	Subtraction: Pop two values a and b, then push the result of b-a
  # *	Multiplication: Pop two values a and b, then push the result of a*b
  # /	Integer division: Pop two values a and b, then push the result of b/a, rounded down. According to the specifications, if a is zero, ask the user what result they want.
  # %	Modulo: Pop two values a and b, then push the remainder of the integer division of b/a.
  # !	Logical NOT: Pop a value. If the value is zero, push 1; otherwise, push zero.
  # `	Greater than: Pop two values a and b, then push 1 if b>a, otherwise zero.
  # >	PC direction right
  # <	PC direction left
  # ^	PC direction up
  # v	PC direction down
  # ?	Random PC direction
  # _	Horizontal IF: pop a value; set direction to right if value=0, set to left otherwise
  # |	Vertical IF: pop a value; set direction to down if value=0, set to up otherwise
  # "	Toggle stringmode (push each character's ASCII value all the way up to the next ")
  # :	Duplicate top stack value
  # \	Swap top stack values
  # $	Pop (remove) top stack value and discard
  # .	Pop top of stack and output as integer
  # ,	Pop top of stack and output as ASCII character
  # #	Bridge: jump over next command in the current direction of the current PC
  # g	A "get" call (a way to retrieve data in storage). Pop two values y and x, then push the ASCII value of the character at that position in the program. If (x,y) is out of bounds, push 0
  # p	A "put" call (a way to store a value for later use). Pop three values y, x and v, then change the character at the position (x,y) in the program to the character with ASCII value v
  # &	Get integer from user and push it
  # ~	Get character from user and push it
  # @	End program
  # 0 – 9	Push corresponding number onto the stack

  # Data Structure used:
  alias Esolix.DataStructures.Stack

  import ExUnit.CaptureIO

  # TODO: Add string input mode as alternative to interactive input mode

  @max_width 80
  @max_height 25

  defmodule Befunge93Stack do
    @moduledoc false
    defstruct [:stack, :code, :x, :y, :direction, :string_mode?]
  end

  # Custom Module Errors
  defmodule InvalidDirectionError do
    @moduledoc false
    defexception [:message]

    def exception(direction) do
      message = "Expected 'v', '>', '^' or '<', got '#{direction}'"
      %InvalidDirectionError{message: message}
    end
  end

  @spec eval(String.t(), keyword()) :: String.t()
  @doc """
    Runs Befunge93 Code and returns the IO output as a string.

    ## Examples

      iex> result = Befunge93.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, _params \\ []) do
    capture_io(fn ->
      execute(code)
    end)
  end

  @spec eval_file(String.t(), keyword()) :: String.t()
  @doc """
    Runs Befunge93 Code from a file and returns the IO output as a string.

    ## Examples

      iex> result = Befunge93.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    file
    |> extract_file_contents()
    |> eval(params)
  end

  @spec execute(String.t(), keyword()) :: :ok
  @doc """
    Run Befunge93 Code

    ## Examples

      iex> Befunge93.execute("some hello world code")
      "Hello World!"
      :ok

  """
  def execute(code, _params \\ []) do
    # validate_code(code)

    %Befunge93Stack{
      stack: Stack.init(),
      code: prep_code(code),
      x: 0,
      y: 0,
      direction: ?>,
      string_mode?: false
    }
    |> run()

    :ok
  end

  @spec execute_file(String.t(), keyword()) :: :ok
  @doc """
    Runs Befunge93 Code from a file.

    ## Examples

      iex> result = Befunge93.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def execute_file(file, params \\ []) do
    # validate_file(file)
    file
    |> extract_file_contents()
    |> execute(params)
  end

  defp prep_code(code) do
    code
    |> String.split("\n")
    |> Enum.map(&String.to_charlist(&1))
  end

  defp instruction(%Befunge93Stack{code: code, x: x, y: y}) do
    instruction_at(code, x, y)
  end

  defp instruction_at(code, x, y) do
    line = Enum.at(code, y)
    if line, do: Enum.at(line, x), else: nil
  end

  defp overwrite_at(code, x, y, value) do
    List.replace_at(
      code,
      y,
      Enum.at(code, y)
      |> List.replace_at(x, value)
    )
  end

  defp run(%Befunge93Stack{} = bf_stack) do
    instruction = instruction(bf_stack)
    # debug(bf_stack)

    if instruction == ?@ do
      # End Program
      bf_stack
    else
      run_instruction(bf_stack, instruction)
      |> run()
    end
  end

  defp run_instruction(
         %Befunge93Stack{
           stack: stack,
           code: code,
           x: x,
           y: y,
           direction: direction,
           string_mode?: string_mode?
         } = bf_stack,
         instruction
       ) do
    {x_next, y_next} = next_coordinates(x, y, direction)

    bf_stack = %{bf_stack | x: x_next, y: y_next}

    case {string_mode?, instruction} do
      # String Mode Handlung
      {true, ?"} ->
        %{bf_stack | string_mode?: false}

      {true, instruction} ->
        %{bf_stack | stack: Stack.push(stack, instruction)}

      {false, instruction} ->
        # Execution Mode Handling
        case instruction do
          ?+ ->
            %{bf_stack | stack: Stack.add(stack)}

          ?- ->
            %{bf_stack | stack: Stack.sub(stack, order: :reverse)}

          ?* ->
            %{bf_stack | stack: Stack.mul(stack)}

          ?/ ->
            %{bf_stack | stack: Stack.div(stack, order: :reverse)}

          ?% ->
            %{bf_stack | stack: Stack.apply(stack, &Integer.mod/2, order: :reverse)}

          ?! ->
            %{bf_stack | stack: Stack.logical_not(stack)}

          ?` ->
            %{bf_stack | stack: Stack.greater_than(stack)}

          ?_ ->
            {a, stack} = Stack.pop(stack)

            direction = if a not in [0, nil], do: ?<, else: ?>

            {x, y} = next_coordinates(x, y, direction)
            %{bf_stack | stack: stack, x: x, y: y, direction: direction}

          ?| ->
            {a, stack} = Stack.pop(stack)

            direction = if a not in [0, nil], do: ?^, else: ?v

            {x, y} = next_coordinates(x, y, direction)
            %{bf_stack | stack: stack, x: x, y: y, direction: direction}

          ?" ->
            %{bf_stack | string_mode?: true}

          ?: ->
            %{bf_stack | stack: Stack.duplicate(stack)}

          ?\\ ->
            {[a, b], stack} = Stack.popn(stack, 2)

            %{bf_stack | stack: stack |> Stack.push([a, b])}

          ?$ ->
            {_, stack} = Stack.pop(stack)

            %{bf_stack | stack: stack}

          ?. ->
            {a, stack} = Stack.pop(stack)

            IO.write(a)
            %{bf_stack | stack: stack}

          ?, ->
            {a, stack} = Stack.pop(stack)

            IO.write([a])
            %{bf_stack | stack: stack}

          ?# ->
            {x, y} = next_coordinates(x_next, y_next, direction)

            %{bf_stack | x: x, y: y}

          ?g ->
            {y_get, stack} = Stack.pop(stack)
            {x_get, stack} = Stack.pop(stack)

            %{bf_stack | stack: Stack.push(stack, instruction_at(code, x_get, y_get))}

          ?p ->
            {[y_get, x_get, value], stack} = Stack.popn(stack, 3)

            %{bf_stack | stack: stack, code: overwrite_at(code, x_get, y_get, value)}

          ?& ->
            input = IO.gets("Enter integer") |> String.trim() |> String.to_integer()

            %{bf_stack | stack: Stack.push(stack, input)}

          ?~ ->
            input = IO.gets("Enter character") |> String.to_charlist() |> Enum.at(0)

            %{bf_stack | stack: Stack.push(stack, input)}

          ?\s ->
            bf_stack

          nil ->
            bf_stack

          other ->
            cond do
              # Handle directions
              other in '>v<^?' && direction != other ->
                direction = maybe_randomize(other)

                {x, y} = next_coordinates(x, y, direction)
                %{bf_stack | x: x, y: y, direction: direction}

              other in '0123456789' ->
                %{
                  bf_stack
                  | stack: Stack.push(stack, List.to_string([other]) |> String.to_integer())
                }

              true ->
                bf_stack
            end
        end
    end
  end

  defp next_coordinates(x, y, direction) do
    case direction do
      ?> ->
        {x + 1, y}

      ?^ ->
        {x, y - 1}

      ?< ->
        {x - 1, y}

      ?v ->
        {x, y + 1}

      direction ->
        raise InvalidDirectionError, direction
    end
    |> check_out_of_bounds()
  end

  defp maybe_randomize(direction) do
    if direction == ??, do: Enum.random('>v<^'), else: direction
  end

  defp check_out_of_bounds({x, y}) do
    cond do
      x >= @max_width ->
        {Integer.mod(x, @max_width), y}

      x < 0 ->
        {@max_width + x, y}

      y >= @max_width ->
        {x, Integer.mod(y, @max_height)}

      y < 0 ->
        {x, @max_height + y}

      true ->
        {x, y}
    end
  end

  defp extract_file_contents(file) do
    File.read!(file)
  end

  defp debug(%Befunge93Stack{code: code, x: x, y: y, direction: direction} = bf_stack) do
    IO.puts("---------------------------------------------\n\n\n")

    IO.inspect(bf_stack)
    IO.inspect([direction], label: "dir")
    IO.inspect([instruction(bf_stack)], label: "instr")

    IO.puts("\n\n")

    IO.write("  ")

    Enum.each(0..x, fn l ->
      IO.write(" ")
    end)

    IO.write("|\n")

    IO.write("  ")

    Enum.each(0..x, fn l ->
      IO.write(" ")
    end)

    IO.write("v\n")

    Enum.with_index(code)
    |> Enum.each(fn {line, y_i} ->
      if y_i == y do
        IO.write("-> ")
        IO.write(line)
        IO.write("\n")
      else
        IO.write("   ")
        IO.write(line)
        IO.write("\n")
      end
    end)

    IO.gets("Press enter for next step\n\n")
  end
end
