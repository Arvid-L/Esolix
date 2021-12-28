defmodule Esolix.Langs.Chicken do
  @moduledoc """
  Documentation for the Chicken Module.
  """

  # Data Structure used:
  alias Esolix.DataStructures.Stack
  import ExUnit.CaptureIO

  # I give up, I wasted way too much time on this. I'm losing my mind because the specifications are really unclear (When are things written to output? Why does the online example for "99 chickens" expect to be able to concatenate strings when using the 'add' operation? I hope I never get to meet the person that wrote these joke specifications). Some of the example code from https://esolangs.org/wiki/Chicken is obviously not able to produce "Hello World", even if I go through the program by hand.

  # https://web.archive.org/web/20180420010949/http://torso.me/chicken-spec
  # 0	exit      axe	      Stop execution.
  # 1	chicken	  chicken	  Push the string "chicken" onto the stack.
  # 2	add	      add	      Add two top stack values.
  # 3	subtract  fox	      Subtract two top stack values.
  # 4	multiply	rooster	  Multiply two top stack values.
  # 5	compare	  compare	  Compare two top stack values for equality, push truthy or falsy result onto the stack.
  # 6	load	    pick	    Double wide instruction. Next instruction indicates source to load from. 0 loads from stack, 1 loads from user input. Top of stack points to address/index to load onto stack.
  # 7	store	    peck	    Top of stack points to address/index to store to. The value below that will be popped and stored.
  # 8	jump	    fr	      Top of stack is a relative offset to jump to. The value below that is the condition. Jump only happens if condition is truthy.
  # 9	char	    BBQ	      Interprets the top of the stack as ascii and pushes the corresponding character.
  # 10+	        push		  Pushes the literal number n-10 onto the stack.

  defmodule ChickenStack do
    @moduledoc false
    defstruct [:stack, :instruction_pointer, :instructions]
  end

  # Custom Module Errors
  defmodule IntruderInChickenCoopError do
    @moduledoc false
    defexception message:
                   "Invalid entry in chicken source code: Only \"chicken\" and \"\\n\" allowed."
  end

  defmodule NotEnoughChickenForTheFoxesToEatError do
    @moduledoc false
    defexception [:message]

    def exception([foxes, chickens]) do
      message = "There are #{foxes} foxes trying to eat only #{chickens} chicken(s)"

      %NotEnoughChickenForTheFoxesToEatError{message: message}
    end
  end

  defmodule UndefinedPickError do
    @moduledoc false
    defexception [:message]

    def exception(instruction) do
      message =
        "Invalid instruction after pick instruction: #{instruction}, expected 'axe' or 'chicken'."

      %UndefinedPickError{message: message}
    end
  end

  @spec eval(String.t(), keyword()) :: String.t()
  @doc """
    Runs Chicken Code and returns the IO output as a string.

    ## Examples

      iex> Chicken.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, params \\ []) do
    capture_io(fn ->
      execute(code, params)
    end)
  end

  @spec eval_file(String.t(), keyword()) :: String.t()
  @doc """
    Runs Chicken Code from file and returns the IO output as a string.

    ## Examples

      iex> Chicken.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    file
    |> extract_file_contents()
    |> eval(params)
  end

  @spec execute(String.t(), keyword()) :: :ok
  @doc """
    Run Chicken Code

    ## Examples

      iex> Chicken.execute("some hello world code")
      "Hello World!"

  """
  def execute(code, params \\ []) do
    input = params[:input] || ""

    input =
      case Integer.parse(input) do
        :error ->
          input

        {int, _} ->
          int
      end

    String.split(code, "\n")
    |> validate_code()
    |> translate_into_instructions()
    |> create_stack(input)
    |> run()

    :ok
  end

  @spec execute_file(String.t(), keyword()) :: :ok
  @doc """
    Run Chicken Code from file

    ## Examples

      iex> Chicken.execute_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def execute_file(file, params \\ []) do
    file
    |> extract_file_contents()
    |> execute(params)
  end

  defp extract_file_contents(file) do
    File.read!(file)
  end

  defp validate_code(lines) do
    Enum.each(lines, fn line ->
      String.split(line, " ")
      |> Enum.any?(&(&1 != "chicken" && &1 != ""))
      |> if do
        raise IntruderInChickenCoopError
      end
    end)

    lines
  end

  defp translate_into_instructions(lines) do
    Enum.map(lines, fn line ->
      line
      |> String.split(" ")
      |> Enum.each(fn x -> if x != "chicken", do: IO.inspect(x) end)
    end)

    Enum.map(lines, fn line ->
      line
      |> String.split(" ")
      |> Enum.count(&(&1 == "chicken"))
      |> opcode_to_instruction()
    end)
  end

  defp opcode_to_instruction(opcode) do
    case opcode do
      0 -> "axe"
      1 -> "chicken"
      2 -> "add"
      3 -> "fox"
      4 -> "rooster"
      5 -> "compare"
      6 -> "pick"
      7 -> "peck"
      8 -> "fr"
      9 -> "BBQ"
      n -> "push #{n - 10}"
    end
  end

  defp create_stack(instructions, input) do
    # Stack/Memory looks like this (example):
    # Addr
    #   7: Program Stack Elem 2 <- Program Stack Pointer
    #   6: Program Stack Elem 1
    #   5: Program Stack Elem 0
    #   4: Operation/Instruction 2
    #   3: Operation/Instruction 1
    #   2: Operation/Instruction 0 <- Instruction Pointer
    #   1: Register 2: User Input
    #   0: Register 1: Pointer to Program Stack

    stack =
      Stack.init()
      # Program Stack Pointer
      |> Stack.push(length(instructions) + 2)
      # User Input
      |> Stack.push(input)

    # Push all instructions onto stack
    stack =
      Enum.reduce(instructions, stack, fn instruction, stack_acc ->
        Stack.push(stack_acc, instruction)
      end)

    %ChickenStack{
      stack: stack,
      instruction_pointer: 2,
      # Instructions parameter is not needed for execution, but for debugging
      instructions: instructions
    }
  end

  defp instruction(%ChickenStack{instruction_pointer: instruction_pointer, stack: stack}) do
    Stack.at(stack, instruction_pointer)
  end

  defp next_instruction(%ChickenStack{instruction_pointer: instruction_pointer} = chicken_stack) do
    instruction(%{chicken_stack | instruction_pointer: instruction_pointer + 1})
  end

  defp run(%ChickenStack{} = chicken_stack) do
    # debug(chicken_stack)

    if instruction(chicken_stack) == "axe" do
      chicken_stack
    else
      chicken_stack
      |> run_instruction()
      |> run()
    end
  end

  defp run_instruction(
         %ChickenStack{
           stack: stack,
           instruction_pointer: instruction_pointer
         } = chicken_stack
       ) do
    case instruction(chicken_stack) do
      "chicken" ->
        %{
          chicken_stack
          | stack: Stack.push(stack, "chicken"),
            instruction_pointer: instruction_pointer + 1
        }

      "add" ->
        {chicken_group_1, stack} = Stack.pop(stack)
        {chicken_group_2, stack} = Stack.pop(stack)

        chicken_result =
          if is_binary(chicken_group_1) || is_binary(chicken_group_2) do
            "#{chicken_group_2}#{chicken_group_1}"
          else
            chicken_group_1 + chicken_group_2
          end

        %{
          chicken_stack
          | stack: Stack.push(stack, chicken_result),
            instruction_pointer: instruction_pointer + 1
        }

      "fox" ->
        {foxes, stack} = Stack.pop(stack)
        {chickens, stack} = Stack.pop(stack)

        # if foxes > chickens,
        #   do: raise(NotEnoughChickenForTheFoxesToEatError, [foxes, chickens])

        %{
          chicken_stack
          | stack: Stack.push(stack, chickens - foxes),
            instruction_pointer: instruction_pointer + 1
        }

      "rooster" ->
        {roosters, stack} = Stack.pop(stack)
        {hens, stack} = Stack.pop(stack)

        %{
          chicken_stack
          | stack: Stack.push(stack, roosters * hens),
            instruction_pointer: instruction_pointer + 1
        }

      "compare" ->
        {chicken_group_1, stack} = Stack.pop(stack)
        {chicken_group_2, stack} = Stack.pop(stack)

        %{
          chicken_stack
          | stack: Stack.push(stack, chicken_group_1 == chicken_group_2),
            instruction_pointer: instruction_pointer + 1
        }

      "pick" ->
        {chicken_address, stack} = Stack.pop(stack)

        case next_instruction(chicken_stack) do
          "axe" ->
            IO.write(Stack.at(stack, chicken_address))

            %{
              chicken_stack
              | stack: Stack.push(stack, Stack.at(stack, chicken_address)),
                instruction_pointer: instruction_pointer + 2
            }

          "chicken" ->
            IO.write(Stack.at(stack, 1))

            %{
              chicken_stack
              | stack: Stack.push(stack, Stack.at(stack, 1)),
                instruction_pointer: instruction_pointer + 2
            }

          other_instruction ->
            raise UndefinedPickError, other_instruction
        end

      "peck" ->
        {chicken_address, stack} = Stack.pop(stack)
        {chickens_to_store, stack} = Stack.pop(stack)

        %{
          chicken_stack
          | stack: Stack.store_at(stack, chicken_address, chickens_to_store),
            instruction_pointer: instruction_pointer + 1
        }

      "fr" ->
        {chicken_offset, stack} = Stack.pop(stack)
        {conditional_chicken, stack} = Stack.pop(stack)

        instruction_pointer =
          if chicken_truthy?(conditional_chicken) do
            instruction_pointer + (chicken_offset + 1)
          else
            instruction_pointer + 1
          end

        %{
          chicken_stack
          | stack: stack,
            instruction_pointer: instruction_pointer
        }

      "BBQ" ->
        {charred_chicken, stack} = Stack.pop(stack)

        %{
          chicken_stack
          | stack: Stack.push(stack, List.to_string([charred_chicken])),
            instruction_pointer: instruction_pointer + 1
        }

      push_n ->
        n = String.split(push_n, " ") |> Enum.at(1) |> String.to_integer()

        %{
          chicken_stack
          | stack: Stack.push(stack, n),
            instruction_pointer: instruction_pointer + 1
        }
    end
  end

  defp chicken_truthy?(chicken) do
    cond do
      chicken == true ->
        true

      chicken > 0 ->
        true

      true ->
        false
    end
  end

  defp debug(
         %ChickenStack{
           stack: stack,
           instruction_pointer: instruction_pointer,
           instructions: instructions
         } = chicken_stack
       ) do
    IO.puts("\n\n\n")
    IO.inspect(chicken_stack, limit: :infinity, pretty: true)

    IO.puts("\n\nInstructions:\n")

    Enum.with_index(instructions)
    |> Enum.each(fn {x, index} ->
      unless index + 2 == instruction_pointer,
        do: IO.puts("#{index}: #{x}"),
        else: IO.puts("#{index}: #{x} <----")
    end)

    {_, s} = Enum.reverse(stack.elements) |> Enum.split(length(instructions) + 2)
    IO.puts("\n\nStack:\n")

    # IO.inspect(s, label: "stack")

    Enum.with_index(s)
    |> Enum.reverse()
    |> Enum.each(fn {y, ind} ->
      unless length(s) == ind + 1,
        do: IO.puts("#{ind}: #{y}"),
        else: IO.puts("#{ind}: #{y} <----")
    end)

    IO.puts("\n\n\n")

    if instruction(chicken_stack) == "pick" do
      IO.inspect(instruction(chicken_stack), label: "current_instruction")

      if next_instruction(chicken_stack) == "axe" do
        IO.inspect("from stack at #{Stack.pop(stack) |> elem(0)}", label: "next_instruction")
      else
        IO.inspect("from user input at #{Stack.pop(stack) |> elem(0)}", label: "next_instruction")
      end
    else
      IO.inspect(instruction(chicken_stack), label: "current_instruction")
      IO.inspect(next_instruction(chicken_stack), label: "next_instruction")
    end

    IO.gets("press enter for next instruction\n")
  end
end
