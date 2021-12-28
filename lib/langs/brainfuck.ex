defmodule Esolix.Langs.Brainfuck do
  @moduledoc """
  Documentation for the Brainfuck Module.
  """

  # >	Move the pointer to the right
  # <	Move the pointer to the left
  # +	Increment the memory cell at the pointer
  # -	Decrement the memory cell at the pointer
  # .	Output the character signified by the cell at the pointer
  # ,	Input a character and store it in the cell at the pointer
  # [	Jump past the matching ] if the cell at the pointer is 0
  # ]	Jump back to the matching [ if the cell at the pointer is nonzero

  alias Esolix.DataStructures.Tape
  import ExUnit.CaptureIO

  defmodule BrainfuckTape do
    @moduledoc false
    defstruct code: "",
              instruction_pointer: 0,
              tape: Tape
  end

  @default_tape_params [
    width: 300_000,
    loop: false,
    cell_byte_size: 1,
    initial_cell_value: 0,
    initial_pointer: 0
  ]

  # Custom Module Errors
  defmodule UnbalancedBracketsError do
    @moduledoc false
    defexception message: "Invalid Brainfuck Code caused by unbalanced square brackets"
  end

  defmodule WrongFileExtensionError do
    @moduledoc false
    defexception [:message]

    def exception(file) do
      msg = "File #{file} does not have the .bf extension"
      %WrongFileExtensionError{message: msg}
    end
  end

  @spec eval(String.t(), keyword()) :: String.t()
  @doc """
    Runs Brainfuck Code and returns the IO output as a string.

    ## Examples

      iex> Template.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, params \\ []) do
    capture_io(fn ->
      execute(code, params)
    end)
  end

  @spec eval_file(String.t(), keyword()) :: String.t()
  @doc """
    Runs Brainfuck Code from file and returns the IO output as a string.

    ## Examples

      iex> Template.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    validate_file(file)
    |> extract_file_contents()
    |> eval(params)
  end

  @spec execute_alt(String.t(), keyword()) :: :ok
  def execute_alt(code, params \\ []) do
    code =
      clean_code(code)
      |> validate_code()

    bf_code = %BrainfuckTape{code: code, tape: init_tape(params)}

    run_step(bf_code)

    :ok
  end

  @spec execute(String.t(), keyword()) :: :ok
  @doc """
    Run Brainfuck Code

    ## Examples

      iex> Brainfuck.execute("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")
      "Hello World!"

  """
  def execute(code, params \\ []) do
    code =
      clean_code(code)
      |> validate_code()
      |> List.to_string()

    tape = init_tape(params)

    code
    |> group_by_brackets()
    |> Enum.reduce(tape, fn section, tape_acc ->
      run_section(section, tape_acc)
    end)

    :ok
  end

  @spec execute_file(String.t(), keyword()) :: :ok
  @doc """
    Run Brainfuck Code from file

    ## Examples

      iex> Brainfuck.execute_file("path/to/hello_world.bf")
      "Hello World!"

  """
  def execute_file(file, params \\ []) do
    validate_file(file)
    |> extract_file_contents()
    |> execute(params)
  end

  defp run_step(
         %BrainfuckTape{code: code, tape: tape, instruction_pointer: instruction_pointer} =
           bf_code
       ) do
    instruction = Enum.at(code, instruction_pointer)
    # debug(bf_code, code: false)

    tape = run_instruction(instruction, tape)

    instruction_pointer =
      case instruction do
        ?[ ->
          # Skip to next ']' if current cell 0
          if Tape.value(tape) == 0 do
            Enum.split(code, instruction_pointer)
            |> elem(1)
            |> Enum.reduce_while({0, 0}, fn char, {index, open_brackets} ->
              open_brackets =
                case char do
                  ?[ ->
                    open_brackets + 1

                  ?] ->
                    open_brackets - 1

                  _ ->
                    open_brackets
                end

              if open_brackets == 0 do
                {:halt, index}
              else
                {:cont, {index + 1, open_brackets}}
              end
            end)
            |> Kernel.+(instruction_pointer)
          else
            instruction_pointer + 1
          end

        ?] ->
          # Jump back to previous '[' if current cell not zero
          if Tape.value(tape) != 0 do
            subtractor =
              Enum.split(code, instruction_pointer)
              |> elem(0)
              |> Enum.reverse()
              |> Enum.reduce_while({0, 1}, fn char, {index, open_brackets} ->
                open_brackets =
                  case char do
                    ?[ ->
                      open_brackets - 1

                    ?] ->
                      open_brackets + 1

                    _ ->
                      open_brackets
                  end

                if open_brackets == 0 do
                  {:halt, index}
                else
                  {:cont, {index + 1, open_brackets}}
                end
              end)
              |> Kernel.+(1)

            instruction_pointer - subtractor
          else
            instruction_pointer + 1
          end

        _ ->
          instruction_pointer + 1
      end

    if instruction_pointer < length(code) do
      run_step(%{bf_code | instruction_pointer: instruction_pointer, tape: tape})
    end
  end

  defp init_tape(params \\ []) do
    tape_params = params[:tape_params] || @default_tape_params
    input = params[:input] || ""
    tape_params = tape_params ++ [input: input]

    params[:tape] || Tape.init(tape_params)
  end

  defp validate_file(file) do
    if String.ends_with?(file, ".bf"), do: file, else: raise(WrongFileExtensionError, file)
  end

  defp extract_file_contents(file) do
    File.read!(file)
  end

  defp clean_code(code) do
    symbols = '[]+-,.<>'

    String.to_charlist(code)
    |> Enum.filter(fn char ->
      Enum.any?(symbols, &(&1 == char))
    end)
  end

  defp validate_code(code) do
    # TODO if brackets are balnced also check if they are positioned correctly to catch cases like "]+++["
    unless Enum.count(code, &(&1 == ?[)) == Enum.count(code, &(&1 == ?])) do
      raise UnbalancedBracketsError
    end

    code
  end

  defp run_section(code, tape) do
    cond do
      # Case 1: Skip Section and jump behind corresponding "]"
      String.starts_with?(code, "[") && Tape.value(tape) == 0 ->
        tape

      # Case 2: Run Section between []-brackets, at the end decide if the bracket section needs to be done another time
      String.starts_with?(code, "[") ->
        tape =
          String.slice(code, 1..-2)
          |> group_by_brackets()
          |> Enum.reduce(tape, fn section, tape_acc ->
            run_section(section, tape_acc)
          end)

        # Reached end of bracket section, if current cell != 0 do it again
        if Tape.value(tape) != 0, do: run_section(code, tape), else: tape

      # Case 3: Run single instructions
      true ->
        code
        |> String.to_charlist()
        |> Enum.reduce(tape, fn char, tape_acc ->
          run_instruction(char, tape_acc)
        end)
    end
  end

  defp group_by_brackets(code) do
    # https://stackoverflow.com/a/19863847/12954117
    # https://www.regular-expressions.info/recurse.html#balanced
    regex = ~r/\[(?>[^\[\]]|(?R))*\]/
    Regex.split(regex, code, include_captures: true)
  end

  defp run_instruction(char, tape) do
    case char do
      ?> -> Tape.right(tape)
      ?< -> Tape.left(tape)
      ?+ -> Tape.inc(tape)
      ?- -> Tape.dec(tape)
      ?. -> Tape.print(tape, mode: :ascii)
      ?, -> Tape.handle_input(tape)
      ?[ -> tape
      ?] -> tape
      _ -> tape
    end
  end

  defp debug(
         %BrainfuckTape{code: code, instruction_pointer: instruction_pointer, tape: tape} =
           bf_code,
         opts \\ []
       ) do
    if opts[:code] do
      IO.inspect(
        List.replace_at(
          code,
          instruction_pointer,
          " ''''  #{[Enum.at(code, instruction_pointer)]}  '''' "
        )
        |> List.to_string(),
        label: "code"
      )
    end

    IO.inspect("#{[Enum.at(code, instruction_pointer)]}", label: "#{instruction_pointer}")
    IO.inspect("#{Tape.cell(tape)}", label: "cell#{tape.pointer}")
    IO.puts("\n")
    IO.puts("\n")
    IO.puts("\n")
  end
end
