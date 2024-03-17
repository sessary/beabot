defmodule BeabotTest do
  use ExUnit.Case
  doctest Beabot

  test "greets the world" do
    assert Beabot.hello() == :world
  end
end
