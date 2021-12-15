defmodule Esolix.Langs.ChickenTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Chicken

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert capture_io(fn ->
        Chicken.eval("some code")
      end) == "Hello World!\n"
    end

  describe "eval_file/3" do
    test "hello_world file should print \"Hello World!\"" do
      assert capture_io(fn ->
        Chicken.eval_file("test/langs/chicken/hello_world")
      end) == "Hello World!\n"
    end
  end

end
