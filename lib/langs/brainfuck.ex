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

  alias Esolix.Memory.Tape

  @default_tape_params [width: 300000, loop: false, cell_byte_size: 1, initial_cell_value: 0, initial_pointer: 0]

    @doc """
      Run Brainfuck Code

      ## Examples

          iex> Brainfuck.eval("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")
          "Hello World!"

    """
  def eval(code, input \\ "", opts \\ []) do
    tape_params = opts[:tape_params] || @default_tape_params
    tape_params = tape_params ++ [input: input]

    tape = Tape.init(tape_params)

    code |> group_by_brackets()
    |> Enum.reduce(tape, fn section, tape_acc ->
      run_section(section, tape_acc)
    end)

    :ok
  end

  defp run_section(code, tape) do
    cond do
      # Case 1: Skip Section and jump behind corresponding "]"
      String.starts_with?(code, "[") && Tape.cell(tape) == 0 ->
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
        if Tape.cell(tape) != 0, do: run_section(code, tape), else: tape
      # Case 3: Run single instructions
      true ->
        code |> String.to_charlist()
        |> Enum.reduce(tape, fn char, tape_acc ->
          execute_char(char, tape_acc)
        end)
    end
  end

  defp group_by_brackets(code) do
    # https://stackoverflow.com/a/19863847/12954117
    # https://www.regular-expressions.info/recurse.html#balanced
    regex = ~r/\[(?>[^\[\]]|(?R))*\]/
    Regex.split(regex, code, include_captures: true)
  end

  defp execute_char(char, tape) do
    case [char] do
      '>' -> Tape.right(tape)
      '<' -> Tape.left(tape)
      '+' -> Tape.inc(tape)
      '-' -> Tape.dec(tape)
      '.' -> Tape.print(tape, mode: :ascii)
      ',' -> Tape.handle_input(tape)
      '[' -> tape
      ']' -> tape
      _ -> tape
    end
  end

end
