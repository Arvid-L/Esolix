defmodule Esolix.Langs.BrainfuckTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Brainfuck

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert Brainfuck.eval("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.") == "Hello World!\n"
    end

    test "should mirror input" do
      assert Brainfuck.eval(",.,.,.,.,.,.", input: "hello!") == "hello!"
    end

    # https://esolangs.org/wiki/Brainfuck#Examples and scroll to Cell Size
    test "should calculate cell byte size correctly for 1 byte" do
      assert Brainfuck.eval("""
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
               """) == "8 bit cells\n"
    end

    test "should calculate cell byte size correctly for 2 bytes" do
      assert Brainfuck.eval(
                 """
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
                 """,
                 tape_params: [cell_byte_size: 2]
               ) == "16 bit cells\n"
    end

    test "should calculate cell byte size correctly for 4 bytes" do
      assert Brainfuck.eval(
                 """
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
                 """,
                 tape_params: [cell_byte_size: 4]
               ) == "32 bit cells\n"
    end
  end

  describe "eval_file/3" do
    test "should throw error on wrong file extension" do
      assert_raise Esolix.Langs.Brainfuck.WrongFileExtensionError, fn ->
        Brainfuck.eval_file("not_a_brainfuck_file.png")
      end
    end

    test "hello_world.bf should print \"Hello World!\"" do
      assert Brainfuck.eval_file("test/langs/brainfuck/hello_world.bf") == "Hello World!\n"
    end

    test "byte_size.bf should calculate correct byte size" do
      assert Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf",
                 tape_params: [cell_byte_size: 1]
               ) == "8 bit cells\n"

      assert Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf",
                 tape_params: [cell_byte_size: 2]
               ) == "16 bit cells\n"

      assert Brainfuck.eval_file("test/langs/brainfuck/byte_size.bf",
                 tape_params: [cell_byte_size: 4]
               ) == "32 bit cells\n"
    end
  end
end
