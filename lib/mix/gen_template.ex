defmodule Mix.Tasks.Template.Gen do
  @moduledoc "Mix task for evaluating Template Code"
  use Mix.Task

  @path_mix "#{File.cwd!}/lib/mix"
  @path_lang "#{File.cwd!}/lib/langs"
  @path_test "#{File.cwd!}/test/langs"

  def run(args) do
    case length(args) do
      0 ->
        IO.warn("No Argument provided to Mix Task.")
      _ ->
        arg = Enum.at(args, 0)

        System.cmd("cp", ["#{@path_mix}/_template.ex", "#{@path_mix}/#{arg}.ex"])
        System.cmd("gsed", ["-ri", "s/Template/#{String.capitalize(arg)}/", "#{@path_mix}/#{arg}.ex"])

        System.cmd("cp", ["#{@path_lang}/_template.ex", "#{@path_lang}/#{arg}.ex"])
        System.cmd("gsed", ["-ri", "s/Template/#{String.capitalize(arg)}/", "#{@path_lang}/#{arg}.ex"])

        System.cmd("mkdir", ["#{@path_test}/#{arg}"])
        System.cmd("cp", ["#{@path_test}/_template.exs", "#{@path_test}/#{arg}/#{arg}_test.exs"])
        System.cmd("gsed", ["-ri", "s/Template/#{String.capitalize(arg)}/", "#{@path_test}/#{arg}/#{arg}_test.exs"])
        System.cmd("gsed", ["-ri", "s/template/#{arg}/", "#{@path_test}/#{arg}/#{arg}_test.exs"])

    end
  end

end
