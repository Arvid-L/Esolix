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
  @doc """
    Pushes a value or a list of values onto the stack. Returns a stack.

    ## Examples

      iex> Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2)
      %Stack{elements: [2, 1, 0]}
      iex> Stack.init() |> Stack.push([3, 4, 5])
      %Stack{elements: [5, 4, 3]}
  """
  def push(stack, elements) when is_list(elements) do
    Enum.reduce(elements, stack, fn element, stack_acc ->
      Stack.push(stack_acc, element)
    end)
  end

  def push(stack, element) do
    %Stack{stack | elements: [element | stack.elements]}
  end

  @spec pushn(t(), list(), non_neg_integer()) :: t()
  @doc """
    Pushes a single value `n` times on the stack. Returns a stack.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.pushn(33, 3)
      %Stack{elements: [33, 33, 33, 0]}
  """
  def pushn(%Stack{} = stack, value, n) do
    Stack.push(stack, List.duplicate(value, n))
  end

  @spec pop(t()) :: {any(), t()}
  def pop(%Stack{elements: []}), do: {0, %Stack{}}

  def pop(%Stack{elements: [top | rest]}) do
    {top, %Stack{elements: rest}}
  end

  @spec popn(t(), non_neg_integer()) :: {list(), t()}
  @doc """
    Pops `n` elements off the stack. Returns a tuple, containing the list of popped values and the stack after the pop operations.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2) |> Stack.push(3)
      %Stack{elements: [3, 2, 1, 0]}
      iex> Stack.popn(stack, 3)
      {[3, 2, 1], %Stack{elements: [0]}}
  """
  def popn(%Stack{} = stack, n) do
    {popped_elements, stack} =
      Enum.reduce(Enum.to_list(1..n), {[], stack}, fn _i, acc ->
        {popped_elements, stack} = acc
        {popped_element, stack} = Stack.pop(stack)

        {[popped_element | popped_elements], stack}
      end)

    {Enum.reverse(popped_elements), stack}
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
      %Stack{elements: [1, 0]}
      iex> Stack.sub(stack, order: [1, 0])
      %Stack{elements: [-1, 0]}
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
    Pops two elements off the stack, divdes them according to :order and pushes the result. Will use integer division by default. Set `:integer` to false for normal division.

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
      Stack.apply(stack, &Kernel.div/2, order: order)
    else
      Stack.apply(stack, &Kernel.//2, order: order)
    end
  end

  @spec logical_not(t(), keyword()) :: t()
  @doc """
    Pops one element off the stack, then pushes `0` back on the stack if the value is non-zero, `1` otherwise.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(33)
      %Stack{elements: [33]}
      iex> stack = Stack.logical_not(stack)
      %Stack{elements: [0]}
      iex> Stack.logical_not(stack)
      %Stack{elements: [1]}
  """
  def logical_not(%Stack{} = stack, opts \\ []) do
    Stack.apply(stack, &if(&1 == 0, do: 1, else: 0), opts)
  end

  @spec greater_than(t(), keyword()) :: t()
  @doc """
    Pops two elements, `top` and `bottom` off the stack. Pushes 1 on the stack if `bottom` > `top`, otherwise pushes `0`. Can be reversed by calling function with `order: :reverse`.

    ## Examples

      iex> stack = Stack.init() |> Stack.push([10, 20])
      %Stack{elements: [20, 10]}
      iex> stack = Stack.greater_than(stack)
      %Stack{elements: [0]}
      iex> Stack.greater_than(stack, order: [1, 0])
      %Stack{elements: [1]}
      iex> Stack.greater_than(stack, order: :reverse)
      %Stack{elements: [1]}
  """
  def greater_than(%Stack{} = stack, opts \\ []) do
    Stack.apply(stack, &if(&2 > &1, do: 1, else: 0), opts)
  end

  @spec duplicate(t(), keyword()) :: t()
  @doc """
    Pops one element off the stack, then pushes that element twice back onto the stack.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(3)
      %Stack{elements: [3]}
      iex> stack = Stack.duplicate()
      %Stack{elements: [3, 3]}
      iex> stack = Stack.duplicate()
      %Stack{elements: [3, 3, 3]}
  """
  def duplicate(%Stack{} = stack, opts \\ []) do
    {value, stack} = Stack.pop(stack)

    Stack.push(stack, [value, value])
  end

  @spec apply(t(), function(), keyword()) :: t()
  @doc """
    Using the provided function `fun/n`, pops `n` elements off the stack and uses them as arguments for `fun/n`. Result will be pushed onto the stack.

    The `:order` of the arguments can be set by the `:order` parameter, which defaults to [0, 1, ..., arity].

    Example: Using the function &Kernel.-/2 will default to: `first_element_popped - second_element_popped`. Using `order: [1, 0]` will result in `second_element_popped - first_element_popped`.

    ## Examples

      iex> stack = Stack.init() |> Stack.push(0) |> Stack.push(1) |> Stack.push(2)
      %Stack{elements: [2, 1, 0]}
      iex> Stack.apply(stack, &Kernel.+/2)
      %Stack{elements: [3, 0]}
      iex> Stack.apply(stack, &Kernel.-/2, order: [0, 1])
      %Stack{elements: [1, 0]}
      iex> Stack.apply(stack, &Kernel.-/2, order: [1, 0])
      %Stack{elements: [-1, 0]}
      iex> Stack.apply(stack, &Kernel.-/2, order: :reverse)
      %Stack{elements: [-1, 0]}
  """
  def apply(%Stack{} = stack, fun, opts \\ []) do
    arity = Keyword.get(:erlang.fun_info(fun), :arity)
    order = Keyword.get(opts, :order, 0..(arity - 1) |> Enum.to_list())

    order =
      if order == :reverse do
        (arity - 1)..0 |> Enum.to_list()
      else
        order
      end

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
