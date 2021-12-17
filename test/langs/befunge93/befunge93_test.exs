defmodule Esolix.Langs.Befunge93Test do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Befunge93

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert capture_io(fn ->
        Befunge93.eval("some code")
      end) == "Hello World!\n"
    end
  end

  describe "eval_file/3" do
    test "hello_world file should print \"Hello World!\"" do
      assert capture_io(fn ->
        Befunge93.eval_file("test/langs/befunge93/hello_world")
      end) == "Hello World!\n"
    end
  end

end
