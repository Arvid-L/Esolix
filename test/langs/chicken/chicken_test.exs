# defmodule Esolix.Langs.ChickenTest do
#   use ExUnit.Case, async: true
#   import ExUnit.CaptureIO

#   alias Esolix.Langs.Chicken

#   @hello_world """
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken
#   chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken

#   chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken

#   chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken
#   chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken

#   chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken

#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken

#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken
#   chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
#

#   """

#   describe "eval/3" do
#     test "Example code should print \"Hello World!\"" do
#       assert capture_io(fn ->
#                Chicken.eval()
#              end) == "Hello World!\n"
#     end
#   end

#   describe "eval_file/3" do
#     test "hello_world file should print \"Hello World!\"" do
#       assert capture_io(fn ->
#                Chicken.eval_file("test/langs/chicken/hello_world")
#              end) == "Hello World!\n"
#     end

#     test "cat file should mirror input" do
#       assert capture_io(fn ->
#                Chicken.eval_file("test/langs/chicken/cat", "input_string")
#              end) == "input_string"
#     end

#     test "99 chicken file should do 99 chickens" do
#       assert capture_io(fn ->
#                Chicken.eval_file("test/langs/chicken/99_chickens")
#              end) == "add this later"
#     end
#   end
# end
