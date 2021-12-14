defmodule Esolix.Memory.Tape do
  @moduledoc """
  Documentation for the simulated turing-like tape used by different esolangs.
  """
  defstruct [
    width: 300000,
    pointer: 0,
    cells: [],
    loop: false
  ]

  alias Esolix.Memory.Tape

  def init(params \\ []) do
    width = params[:width] || 300000
    intital_pointer = params[:initial_pointer] || 0
    initial_cell_value = params[:initial_cell_value] || 0
    loop = params[:loop] || false

    cells = List.duplicate(initial_cell_value, width)

    %Tape{pointer: intital_pointer, cells: cells, width: width, loop: loop}
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

  def inc(%Tape{pointer: pointer, cells: cells} = tape) do
    cells =
      Enum.with_index(cells)
      |> Enum.map(fn {cell, index} ->
        if index == pointer, do: cell + 1, else: cell
      end)

    %{tape | cells: cells}
  end

  def dec(%Tape{pointer: pointer, cells: cells} = tape) do
    cells =
      Enum.with_index(cells)
      |> Enum.map(fn {cell, index} ->
        if index == pointer, do: cell - 1, else: cell
      end)

    %{tape | cells: cells}
  end

  def print(%Tape{pointer: pointer, cells: cells} = _tape, opts \\ []) do
    data =
      case opts[:mode] do
        :ascii ->
          List.to_string([Enum.at(cells, pointer)])
        _ ->
          Enum.at(cells, pointer)
      end

    IO.write(data)
  end

  defp validate_boundary(%Tape{pointer: pointer, width: width, loop: loop} = tape) do
    pointer =
      cond do
        pointer >= width && loop ->
          rem(pointer, width)
        pointer < 0 && loop ->
          width - 1
        (pointer >= width || pointer < 0) ->
          raise "Tape Pointer is out of Bounds"
        true ->
          pointer
      end

    %{tape | pointer: pointer}
  end

end
