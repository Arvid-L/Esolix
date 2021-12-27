defmodule Esolix.DataStructures.Stack do
  @moduledoc """
  Documentation for the simulated stack used by different esolangs.
  """

  alias Esolix.DataStructures.Stack

  defstruct elements: []

  @typedoc """
  LIFO Stack containing a list of elements.
  """
  @type t :: %Stack{elements: list()}

  def init, do: %Stack{}

  ################################################
  # Standard Stack Operations (Push, Pop, Depth) #
  ################################################

  @spec push(t(), any()) :: t()
  def push(stack, elements) when is_list(elements) do
    Enum.reduce(elements, stack, fn element, stack_acc ->
      Stack.push(stack_acc, element)
    end)
  end

  def push(stack, element) do
    %Stack{stack | elements: [element | stack.elements]}
  end

  @spec pop(t()) :: {any(), t()}
  def pop(%Stack{elements: []}), do: {0, %Stack{}}

  def pop(%Stack{elements: [top | rest]}) do
    {top, %Stack{elements: rest}}
  end

  @spec popn(t(), non_neg_integer()) :: {list(), t()}
  def popn(%Stack{} = stack, n) do
    Enum.reduce(Enum.to_list(1..n), {[], stack}, fn _i, acc ->
      {arguments, stack} = acc
      {argument, stack} = Stack.pop(stack)

      {[argument | arguments], stack}
    end)
  end

  @spec depth(t()) :: non_neg_integer
  def depth(%Stack{elements: elements}), do: length(elements)

  ########################################
  # Common Non-standard Stack Operations #
  ########################################

  @spec add(t(), keyword()) :: t()
  @doc """
    Pops two elements off the stack, adds them and pushes the result.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2)
      %Stack{elements: [2, 1, 0]}
      iex> Stack.add(stack)
      %Stack{elements: [3, 0]}
  """
  def add(%Stack{} = stack, opts \\ []),
    do: Stack.apply(stack, &Kernel.+/2, order: Keyword.get(opts, :order, [0, 1]))

  @spec sub(t(), keyword()) :: t()
  @doc """
    Pops two elements off the stack, subtracts them according to `:order` and pushes the result.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2)
      %Stack{elements: [2, 1, 0]}
      iex> Stack.sub(stack)
      %Stack{elements: [-1, 0]}
      iex> Stack.sub(stack, order: [1, 0])
      %Stack{elements: [1, 0]}
  """
  def sub(%Stack{} = stack, opts \\ []),
    do: Stack.apply(stack, &Kernel.-/2, order: Keyword.get(opts, :order, [0, 1]))

  @spec mul(t()) :: t()
  @doc """
    Pops two elements off the stack, multiplies them and pushes the result.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(2) |> Stack.push(4)
      %Stack{elements: [4, 2, 0]}
      iex> Stack.mul(stack)
      %Stack{elements: [8, 0]}
  """
  def mul(%Stack{} = stack) do
    Stack.apply(stack, &Kernel.*/2)
  end

  @spec div(t(), keyword()) :: t()
  @doc """
    Pops two elements off the stack, divdes them according to :order and pushes the result.

    Will use integer division by default. Set `:integer` to false for normal division.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(2) |> Stack.push(5)
      %Stack{elements: [5, 2, 0]}
      iex> Stack.div(stack)
      %Stack{elements: [2, 0]}
      iex> Stack.div(stack, integer: false)
      %Stack{elements: [2.5, 0]}
  """
  def div(%Stack{} = stack, opts \\ []) do
    order = Keyword.get(opts, :order, [0, 1])
    integer_division = Keyword.get(opts, :integer, true)

    if integer_division do
      Stack.apply(stack, &Kernel.//2, order: order)
    else
      Stack.apply(stack, &Kernel.div/2, order: order)
    end
  end

  @spec apply(t(), function(), keyword()) :: t()
  @doc """
    Using the provided function `fun/n`, pops `n` elements off the stack and uses them as arguments for `fun/n`. Result will be pushed onto the stack.

    The `:order` of the arguments can be set by the `:order` parameter, which defaults to [0, 1, ..., arity].

    Example: Using the function &Kernel.-/2 will default to: `second_element_popped - first_element_popped`, as counting starts from the bottom of stack. Using `order: [1, 0]` will result in `first_element_popped - second_element_popped`.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2)
      %Stack{elements: [2, 1, 0]}
      iex> Stack.apply(stack, &Kernel.+/2)
      %Stack{elements: [3, 0]}
      iex> Stack.apply(stack, &Kernel.-/2, order: [0, 1])
      %Stack{elements: [-1, 0]}
      iex> Stack.apply(stack, &Kernel.-/2, order: [1, 0])
      %Stack{elements: [1, 0]}
  """
  def apply(%Stack{} = stack, fun, opts \\ []) do
    arity = Keyword.get(:erlang.fun_info(fun), :arity)
    order = Keyword.get(opts, :order, 0..(arity - 1) |> Enum.to_list())

    if arity != length(order),
      do:
        raise(
          "Number of elements in argument order list (#{length(order)}) does not match function arity (#{arity})"
        )

    {arguments, stack} = Stack.popn(stack, arity)
    arguments = order_arguments(arguments, order)

    result = Kernel.apply(fun, arguments)

    Stack.push(stack, result)
  end

  @spec at(t(), integer()) :: any()
  def at(%Stack{elements: elements}, address) do
    address = address + 1
    Enum.at(elements, -address)
  end

  @spec store_at(t(), integer(), any()) :: t()
  def store_at(%Stack{elements: elements}, address, value) do
    address = address + 1
    %Stack{elements: List.replace_at(elements, -address, value)}
  end

  defp order_arguments(arguments, order) do
    Enum.map(order, fn ordinal ->
      Enum.at(arguments, ordinal)
    end)
  end
end
