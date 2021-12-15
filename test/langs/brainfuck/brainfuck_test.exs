defmodule Esolix.Langs.BrainfuckTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Brainfuck

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert capture_io(fn ->
        Brainfuck.eval("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")
      end) == "Hello World!\n"
    end

    test "should mirror input" do
      assert capture_io(fn ->
        Brainfuck.eval(",.,.,.,.,.,.", [input: "hello!"])
      end) == "hello!"
    end

    # https://esolangs.org/wiki/Brainfuck#Examples and scroll to Cell Size
    test "should calculate cell byte size correctly for 1 byte" do
      assert capture_io(fn ->
        Brainfuck.eval("""
        Calculate the value 256 and test if it's zero
        If the interpreter errors on overflow this is where it'll happen
        ++++++++[>++++++++<-]>[<++++>-]
        +<[>-<
            Not zero so multiply by 256 again to get 65536
            [>++++<-]>[<++++++++>-]<[>++++++++<-]
            +>[>
                # Print "32"
                ++++++++++[>+++++<-]>+.-.[-]<
            <[-]<->] <[>>
                # Print "16"
                +++++++[>+++++++<-]>.+++++.[-]<
        <<-]] >[>
            # Print "8"
            ++++++++[>+++++++<-]>.[-]<
        <-]<
        # Print " bit cells\n"
        +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
        >>.++.+++++++..<-.>>-
        Clean up used cells.
        [[-]<]
        """)
      end) == "8 bit cells\n"
    end

    test "should calculate cell byte size correctly for 2 bytes" do
      assert capture_io(fn ->
        Brainfuck.eval("""
        Calculate the value 256 and test if it's zero
        If the interpreter errors on overflow this is where it'll happen
        ++++++++[>++++++++<-]>[<++++>-]
        +<[>-<
            Not zero so multiply by 256 again to get 65536
            [>++++<-]>[<++++++++>-]<[>++++++++<-]
            +>[>
                # Print "32"
                ++++++++++[>+++++<-]>+.-.[-]<
            <[-]<->] <[>>
                # Print "16"
                +++++++[>+++++++<-]>.+++++.[-]<
        <<-]] >[>
            # Print "8"
            ++++++++[>+++++++<-]>.[-]<
        <-]<
        # Print " bit cells\n"
        +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
        >>.++.+++++++..<-.>>-
        Clean up used cells.
        [[-]<]
        """, tape_params: [cell_byte_size: 2])
      end) == "16 bit cells\n"
    end

    test "should calculate cell byte size correctly for 4 bytes" do
      assert capture_io(fn ->
        Brainfuck.eval("""
        Calculate the value 256 and test if it's zero
        If the interpreter errors on overflow this is where it'll happen
        ++++++++[>++++++++<-]>[<++++>-]
        +<[>-<
            Not zero so multiply by 256 again to get 65536
            [>++++<-]>[<++++++++>-]<[>++++++++<-]
            +>[>
                # Print "32"
                ++++++++++[>+++++<-]>+.-.[-]<
            <[-]<->] <[>>
                # Print "16"
                +++++++[>+++++++<-]>.+++++.[-]<
        <<-]] >[>
            # Print "8"
            ++++++++[>+++++++<-]>.[-]<
        <-]<
        # Print " bit cells\n"
        +++++++++++[>+++>+++++++++>+++++++++>+<<<<-]>-.>-.+++++++.+++++++++++.<.
        >>.++.+++++++..<-.>>-
        Clean up used cells.
        [[-]<]
        """, tape_params: [cell_byte_size: 4])
      end) == "32 bit cells\n"
    end
  end

  describe "eval_file/3" do
    test "should throw error on wrong file extension" do
      assert_raise Esolix.Langs.Brainfuck.WrongFileExtensionError, fn ->
        Brainfuck.eval_file("not_a_brainfuck_file.png")
      end
    end

    test "hello_world.bf should print \"Hello World!\"" do
      assert capture_io(fn ->
        Brainfuck.eval_file("test/langs/brainfuck/hello_world.bf")
      end) == "Hello World!\n"
    end

    test "byte_size.bf should calculate correct byte size" do
      assert capture_io(fn ->
        Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf", tape_params: [cell_byte_size: 1])
      end) == "8 bit cells\n"

      assert capture_io(fn ->
        Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf", tape_params: [cell_byte_size: 2])
      end) == "16 bit cells\n"

      assert capture_io(fn ->
        Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf", tape_params: [cell_byte_size: 4])
      end) == "32 bit cells\n"
    end
  end


end
