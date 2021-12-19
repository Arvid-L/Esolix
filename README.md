# Esolix
Collection of different esolang (esoteric programming language) interpreters, implemented in Elixir.

**TODO: Add description**

## Which Esolangs are already (kind of) implemented?

- Befunge-93 (https://esolangs.org/wiki/Befunge#Befunge-93_and_Befunge-98)
- Brainfuck (https://esolangs.org/wiki/Brainfuck)
- Chicken (https://esolangs.org/wiki/Chicken) (don't try this because the specifications for this didn't really make sense)

## Want to add another Esolang?

```sh
mix template.gen somelanguage
```

This will generate three files with a basic structure, which is defined in their corresponding _template.ex files.

- mix/langs/somelanguage.ex -> Mix Task to run the Code from "somelanguage" directly or from a file using "mix somelanguage path/to/file_with_somelanguage_code
- lib/langs/somelanguage.ex -> The module with the interpreter/evaluator/compiler to be implemented for "somelanguage".
- test/langs/somelanguage/somelanguage_test.ex -> Test for the somelanguage Module.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `esolix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:esolix, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/esolix>.

