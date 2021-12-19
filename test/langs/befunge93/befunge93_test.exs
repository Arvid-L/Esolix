defmodule Esolix.Langs.Befunge93Test do
  use ExUnit.Case, async: true
  # import ExUnit.CaptureIO

  alias Esolix.Langs.Befunge93

  @hello_world """
"!dlroW ,olleH">:v
               |,<
               @
"""


  describe "eval/3" do
    test "Example code should print \"Hello World!\"" do
      assert Befunge93.eval(@hello_world) == "Hello, World!\0"
    end

    test "quine code should print itself" do
      assert Befunge93.eval("01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@") == "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@"
    end
  end

  describe "eval_file/3" do
    test "hello_world file should print \"Hello World!\"" do
      assert Befunge93.eval_file("test/langs/befunge93/hello_world") == "Hello, World!\0"
    end

    test "sieve of erastosthenes file should print prime numbers" do
      assert Befunge93.eval_file("test/langs/befunge93/sieve_of_erastosthenes") == "2357111317192329313741434753596167717379"
    end

    test "dna file should print some dna" do
      dna = Befunge93.eval_file("test/langs/befunge93/dna")

      assert String.trim(dna) |> String.length() == 56
      assert String.contains?(dna, "G") && String.contains?(dna, "A") && String.contains?(dna, "T") && String.contains?(dna, "C")
    end

    test "quine file should print itself" do
      assert Befunge93.eval_file("test/langs/befunge93/quine") == "01->1# +# :# 0# g# ,# :# 5# 8# *# 4# +# -# _@"
    end
  end
end
