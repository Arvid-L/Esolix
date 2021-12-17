defmodule Esolix.Langs.TemplateTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Esolix.Langs.Template

  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert capture_io(fn ->
        Template.eval("some code")
      end) == "Hello World!\n"
    end
  end

  describe "eval_file/3" do
    test "hello_world file should print \"Hello World!\"" do
      assert capture_io(fn ->
        Template.eval_file("test/langs/template/hello_world")
      end) == "Hello World!\n"
    end
  end

end
