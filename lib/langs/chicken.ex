defmodule Esolix.Langs.Chicken do
  @moduledoc """
  Documentation for the Chicken Module
  """

  # Data Structure used:
  alias Esolix.DataStructures.Stack

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


  # Custom Module Errors
  defmodule IntruderInChickenCoopError do
    defexception message: "Invalid entry in chicken source code: Only \"chicken\" and \"\\n\" allowed."
  end


  @doc """
    Run Chicken Code

    ## Examples

      iex> Chicken.eval("some hello world code")
      "Hello World!"

  """
  def eval(code, params \\ []) do
    validate_code(code)

    # Do something
  end

  @doc """
    Run Chicken Code from file

    ## Examples

      iex> Chicken.eval_file("path/to/some/hello_world.file")
      "Hello World!"

  """
  def eval_file(file, params \\ []) do
    validate_file(file)
    |> extract_file_contents()
    |> eval(params)
  end

  defp validate_file(file) do
    # Do something
  end

  defp extract_file_contents(file) do
    File.read!(file)
  end

  defp validate_code(code) do
    String.split(code, " ")
    |> Enum.any?( & &1 != "chicken" )
    |> if do
      raise IntruderInChickenCoopError
    end

    code
  end

end
