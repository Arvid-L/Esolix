defmodule Esolix.Langs.BrainfuckTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Brainfuck

  describe "run/1" do
    test "Example code should print \"Hello World!\"" do
      assert Brainfuck.run("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.") == "Hello World!"
    end

    test "should mirror input" do
      assert capture_io(fn ->
        Brainfuck.run(",.,.,.,.,.,.", "hello!")
      end) == "hello!"
    end

    # https://esolangs.org/wiki/Brainfuck#Examples and scroll to Cell Size
    test "should calculate cell byte size correctly for 1 byte" do
      assert capture_io(fn ->
        Brainfuck.run("""
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
        """, [width: 10])
      end) == "8 bit cells\n"
    end

    test "should calculate cell byte size correctly for 2 bytes" do
      assert capture_io(fn ->
        Brainfuck.run("""
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
        """, [cell_byte_size: 2, width: 10])
      end) == "16 bit cells\n"
    end

    test "should calculate cell byte size correctly for 4 bytes" do
      assert capture_io(fn ->
        Brainfuck.run("""
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
        """, [cell_byte_size: 4, width: 10])
      end) == "32 bit cells\n"
    end
  end


end
