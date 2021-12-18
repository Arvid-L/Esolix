defmodule Esolix.DataStructures.Stack do
  @moduledoc """
  Documentation for the simulated stack used by different esolangs.
  """

  alias Esolix.DataStructures.Stack

  defstruct elements: []

  def init, do: %Stack{}

  def push(stack, element) do
    %Stack{stack | elements: [element | stack.elements]}
  end

  def pop(%Stack{elements: []}), do: raise("Stack is empty!")

  def pop(%Stack{elements: [top | rest]}) do
    {top, %Stack{elements: rest}}
  end

  def depth(%Stack{elements: elements}), do: length(elements)

  def at(%Stack{elements: elements}, address) do
    address = address + 1
    Enum.at(elements, -address)
  end

  def store_at(%Stack{elements: elements}, address, value) do
    address = address + 1
    %Stack{elements: List.replace_at(elements, -address, value)}
  end
end
