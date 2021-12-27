defmodule Esolix.Langs.PietTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Piet

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert Piet.eval("some code") == "Hello World!\n"
    end
  end

  describe "eval_file/3" do
    test "hello_world file should print \"Hello World!\"" do
      assert Piet.eval_file("test/langs/piet/hello_world") == "Hello World!\n"
    end
  end
end
