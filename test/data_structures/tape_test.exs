defmodule Esolix.DataStructures.TapeTest do
  use ExUnit.Case, async: true
  alias Esolix.DataStructures.Tape

  @tape Tape.init(cell_byte_size: 1)
  @tape_2_byte Tape.init(cell_byte_size: 2)
  @tape_4_byte Tape.init(cell_byte_size: 4)

  @max_int_1_byte Bitwise.bsl(1, 8) - 1
  @max_int_2_byte Bitwise.bsl(1, 16) - 1
  @max_int_4_byte Bitwise.bsl(1, 32) - 1

  describe "init/1" do
    test "creates Esolix.DataStructures.Tape struct" do
      assert Tape.init().__struct__ == Esolix.DataStructures.Tape
    end
  end


  describe "left/1 or right/1" do
    test "can't go out of bounds on normal tape" do
      assert_raise Esolix.DataStructures.Tape.OutOfBoundsError, fn ->
        Tape.init(width: 1)
        |> Tape.left()
      end

      assert_raise Esolix.DataStructures.Tape.OutOfBoundsError, fn ->
        Tape.init(width: 1)
        |> Tape.right()
      end
    end

    test "can go out of bounds on looped tape" do
      assert Tape.init(loop: true, width: 3)
        |> Tape.left()
        |> Map.get(:pointer) == 2

      assert Tape.init(loop: true, width: 3)
        |> Tape.left()
        |> Tape.right()
        |> Map.get(:pointer) == 0
    end
  end

  describe "cell/1" do
    test "returns correct value (default value)" do
      assert Tape.cell(@tape) == <<0::size(8)>>
    end

    test "returns correct value (custom value)" do
      assert Tape.init([initial_cell_value: 1, width: 5])
        |> Tape.cell()
        == <<1::size(8)>>
    end
  end

  describe "value/1" do
    test "returns correct value (default initial value)" do
      assert Tape.init()
        |> Tape.value() == 0
    end

    test "returns correct value (custom initial value)" do
      assert Tape.init(initial_cell_value: 33)
        |> Tape.value() == 33
    end
  end

  describe "write/1" do
    test "correctly writes integers" do
      assert Tape.init(cell_byte_size: 1)
        |> Tape.write(33)
        |> Tape.value() == 33

      assert Tape.init(cell_byte_size: 1)
        |> Tape.write(289)
        |> Tape.value() == 33

      assert Tape.init(cell_byte_size: 2)
        |> Tape.write(289)
        |> Tape.value() == 289
    end

    test "correctly writes character" do
      assert Tape.init(cell_byte_size: 1)
        |> Tape.write(?!)
        |> Tape.value() == 33
    end
  end

  describe "handle_input/2" do
    test "correctly writes input on tape" do
      assert Tape.init(input: "123")
        |> Tape.handle_input()
        |> Tape.handle_input()
        |> Tape.value() == ?2
    end

    test "correctly save remaining input" do
      assert Tape.init(input: "123")
          |> Tape.handle_input()
          |> Tape.handle_input()
          |> Map.get(:input) == [?3]
    end

    test "correctly handles empty inputs" do
      assert Tape.init(input: "")
        |> Map.get(:input) == []

      assert Tape.init()
        |> Map.get(:input) == []
    end

  end

  describe "inc/1 or dec/1" do
    test "changes value correctly" do
      tape = @tape
      assert Tape.cell(tape) == <<0::size(8)>>

      tape = @tape |> Tape.inc()
      assert Tape.cell(tape) == <<1::size(8)>>

      tape = Tape.dec(tape)
      assert Tape.cell(tape) == <<0::size(8)>>
    end

    test "should underflow correctly" do
      assert @tape
        |> Tape.dec()
        |> Tape.cell() == <<@max_int_1_byte::size(8)>>
      assert @tape_2_byte
        |> Tape.dec()
        |> Tape.cell() == <<@max_int_2_byte::size(16)>>
      assert @tape_4_byte
        |> Tape.dec()
        |> Tape.cell() == <<@max_int_4_byte::size(32)>>
    end

    test "should overflow correctly" do
      assert Tape.init(cell_byte_size: 1, initial_cell_value: @max_int_1_byte)
        |> Tape.inc()
        |> Tape.cell() == <<0::size(8)>>

        assert   Tape.init(cell_byte_size: 2, initial_cell_value: @max_int_2_byte)
          |> Tape.inc()
          |> Tape.cell() == <<0::size(16)>>

        assert   Tape.init(cell_byte_size: 4, initial_cell_value: @max_int_4_byte)
          |> Tape.inc()
          |> Tape.cell() == <<0::size(32)>>
    end
  end



end
