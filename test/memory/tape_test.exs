defmodule TapeTest do
  use ExUnit.Case, async: true
  alias Esolix.Memory.Tape

  @tape Tape.init([width: 5, loop: false])
  @tape_short Tape.init([width: 1, loop: false])
  @tape_looped Tape.init([width: 3, loop: true])

  describe "init/1" do
    test "creates Esolix.Memory.Tape struct" do
      assert Tape.init().__struct__ == Esolix.Memory.Tape
    end
  end


  describe "left/1 or right/1" do
    test "can't go out of bounds on normal tape" do
      assert_raise RuntimeError, fn ->
        Tape.left(@tape_short)
      end

      assert_raise RuntimeError, fn ->
        Tape.right(@tape_short)
      end
    end

    test "can go out of bounds on looped tape" do
      tape =
        @tape_looped
        |> Tape.left()

      assert tape.pointer == 2

      tape = Tape.right(tape)

      assert tape.pointer == 0
    end
  end

  describe "cell/1" do
    test "returns correct value (default)" do
      assert Tape.cell(@tape) == 0
    end

    test "returns correct value (custom)" do
      tape = Tape.init([initial_cell_value: 1, width: 5])

      assert Tape.cell(tape) == 1
    end

  end

  describe "inc/1 or dec/1" do
    test "changes value correctly" do
      assert Tape.cell(@tape) == 0

      tape =
        @tape
        |> Tape.inc()

      assert Tape.cell(tape) == 1

      tape = Tape.dec(tape)

      assert Tape.cell(tape) == 0
    end

  end



end
