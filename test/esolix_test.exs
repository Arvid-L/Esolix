defmodule EsolixTest do
  use ExUnit.Case
  doctest Esolix

  test "greets the world" do
    assert Esolix.hello() == :world
  end
end
