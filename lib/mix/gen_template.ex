defmodule Mix.Tasks.Template.Gen do
  @moduledoc "Mix task to generate template files for a new esolang"
  use Mix.Task

  @path_mix "#{File.cwd!()}/lib/mix"
  @path_lang "#{File.cwd!()}/lib/langs"
  @path_test "#{File.cwd!()}/test/langs"

  @doc """
    Sets up template files for new esolang.
    Generates language module file, mix task file, language module test file.

    ## Examples

    ```sh
    mix template.gen piet
    Created /Esolix/lib/mix/piet.ex
    Created /Esolix/lib/langs/piet.ex
    Created /Esolix/test/langs/piet.exs
  """
  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")

      _ ->
        arg = Enum.at(args, 0)

        # Generate mix task file
        System.cmd("cp", ["#{@path_mix}/_template.ex", "#{@path_mix}/#{arg}.ex"])

        System.cmd("gsed", [
          "-ri",
          "s/Template/#{String.capitalize(arg)}/",
          "#{@path_mix}/#{arg}.ex"
        ])

        IO.puts("Created #{@path_mix}/#{arg}.ex")

        # Generate language module file
        System.cmd("cp", ["#{@path_lang}/_template.ex", "#{@path_lang}/#{arg}.ex"])

        System.cmd("gsed", [
          "-ri",
          "s/Template/#{String.capitalize(arg)}/",
          "#{@path_lang}/#{arg}.ex"
        ])

        IO.puts("Created #{@path_lang}/#{arg}.ex")

        # Generate test file
        System.cmd("mkdir", ["#{@path_test}/#{arg}"])
        System.cmd("cp", ["#{@path_test}/_template.exs", "#{@path_test}/#{arg}/#{arg}_test.exs"])

        System.cmd("gsed", [
          "-ri",
          "s/Template/#{String.capitalize(arg)}/",
          "#{@path_test}/#{arg}/#{arg}_test.exs"
        ])

        System.cmd("gsed", ["-ri", "s/template/#{arg}/", "#{@path_test}/#{arg}/#{arg}_test.exs"])

        IO.puts("Created #{@path_test}/#{arg}.exs")
    end
  end
end
