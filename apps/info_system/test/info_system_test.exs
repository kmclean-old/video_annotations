defmodule InfoSystemTest do
  use ExUnit.Case
  doctest InfoSystem

  test "greets the world" do
    assert InfoSystem.hello() == :world
  end
end
