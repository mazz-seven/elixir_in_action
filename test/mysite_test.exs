defmodule MysiteTest do
  use ExUnit.Case
  doctest Mysite

  test "greets the world" do
    assert Mysite.hello() == :world
  end
end
