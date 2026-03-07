defmodule GoodleadsExTest do
  use ExUnit.Case
  doctest GoodleadsEx

  test "greets the world" do
    assert GoodleadsEx.hello() == :world
  end
end
