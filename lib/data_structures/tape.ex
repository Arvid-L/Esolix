defmodule Esolix.DataStructures.Tape do
  @moduledoc """
  Documentation for the simulated turing-like tape used by different esolangs.
  """
  defstruct [
    width: 300000,
    pointer: 0,
    cells: [],
    cell_bit_size: 8,
    loop: false,
    input: "",
    output: ""
  ]

  # TODO: Optimize, find bottlenecks. Some steps take way too much time
  # TODO: Optimize data structure by using bitstrings instead of Elixirs default bignum

  alias Esolix.DataStructures.Tape

  defmodule OutOfBoundsError do
    defexception [:message]

    def exception(%Tape{} = tape) do
      msg = "Pointer moved out of bounds (address: #{tape.pointer}) on tape with width #{tape.width}"
      %OutOfBoundsError{message: msg}
    end
  end

  def init(params \\ []) do
    width = params[:width] || 30
    intital_pointer = params[:initial_pointer] || 0
    cell_byte_size = params[:cell_byte_size] || 1
    cell_bit_size = cell_byte_size * 8
    initial_cell_value = params[:initial_cell_value] || 0
    loop = params[:loop] || false
    input = params[:input] || ""
    input = String.to_charlist(input)

    cells = List.duplicate(<<initial_cell_value::size(cell_bit_size)>>, width)

    %Tape{pointer: intital_pointer, cells: cells, width: width, loop: loop, cell_bit_size: cell_bit_size, input: input}
  end

  def right(%Tape{pointer: pointer} = tape) do
    %{tape | pointer: pointer + 1}
    |> validate_boundary()
  end

  def left(%Tape{pointer: pointer} = tape) do
    %{tape | pointer: pointer - 1}
    |> validate_boundary()
  end

  def cell(%Tape{pointer: pointer, cells: cells}) do
    Enum.at(cells, pointer)
  end

  def value(%Tape{pointer: pointer, cells: cells, cell_bit_size: cell_bit_size}) do
    <<val::size(cell_bit_size)>> = Enum.at(cells, pointer)
    val
  end

  def inc(%Tape{cell_bit_size: cell_bit_size} = tape) do
    data = Tape.value(tape)
    write(tape, <<data+1::size(cell_bit_size)>>)
  end

  def dec(%Tape{cell_bit_size: cell_bit_size} = tape) do
    data = Tape.value(tape)
    write(tape, <<data-1::size(cell_bit_size)>>)
  end

  def handle_input(%Tape{input: input, cell_bit_size: cell_bit_size} = tape) do
    {tape, input} =
      case length(input) do
        0 ->
          {tape, []}
        _ ->
          [char | remaining_input] = input
          char = <<char::size(cell_bit_size)>>
          {write(tape, char), remaining_input}
      end

    %{tape | input: input}
  end

  defp write(%Tape{cells: cells, pointer: pointer} = tape, data) do
    cells = List.replace_at(cells, pointer, data)
    %{tape | cells: cells}
  end

  def print(%Tape{} = tape, opts \\ []) do
    data =
      case opts[:mode] do
        :ascii ->
          [Tape.value(tape)]
        _ ->
          Tape.value(tape)
      end

    IO.write(data)
    tape
  end

  defp validate_boundary(%Tape{pointer: pointer, width: width, loop: loop} = tape) do
    pointer =
      cond do
        pointer >= width && loop ->
          rem(pointer, width)
        pointer < 0 && loop ->
          width - 1
        (pointer >= width || pointer < 0) ->
          raise OutOfBoundsError, tape
        true ->
          pointer
      end

    %{tape | pointer: pointer}
  end

  # defp validate_overflow(%Tape{cell_byte_size: cell_byte_size}, cell) do
  #   case cell_byte_size do
  #     :no_limit ->
  #       cell
  #     _ ->
  #       max_size = Bitwise.bsl(1, cell_byte_size * 8)
  #       cond do
  #         cell >= max_size ->
  #           rem(cell, max_size)
  #         cell < 0 ->
  #           max_size - 1
  #         true ->
  #           cell
  #       end
  #   end

  # end

end
