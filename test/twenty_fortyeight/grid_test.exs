defmodule TwentyFortyeight.GridTest do
  use ExUnit.Case, async: true

  alias TwentyFortyeight.Grid

  describe "new/2" do
    for size <- [2, 500] do
      test "generates a grid with a specified size: #{size}" do
        grid = Grid.new(unquote(size), 0)

        for line <- grid do
          assert length(line) == unquote(size)
        end
      end
    end

    for value <- ["abc", true, 42] do
      test "generates a grid with any initial value: #{value}" do
        grid = Grid.new(2, unquote(value))

        for line <- grid do
          for element <- line do
            assert element == unquote(value)
          end
        end
      end
    end
  end

  describe "put/4" do
    test "updates a specific position in a grid given two zero-index values" do
      new_value = "something else"

      grid = Grid.new(2, 0)

      assert Grid.get(grid, 1, 1) == 0

      grid = Grid.put(grid, 1, 1, new_value)

      assert Grid.get(grid, 1, 1) == new_value
    end
  end

  describe "get/3" do
    test "returns the value in a position of the grid identified by two zero-index values" do
      grid = Grid.new(2, true)
      assert Grid.get(grid, 0, 0)
    end
  end

  describe "has_value?/2" do
    test "checks if a grid contains a certain value" do
      grid = Grid.new(2, "abc")

      refute Grid.has_value?(grid, 0)
      assert Grid.has_value?(grid, "abc")

      grid = Grid.put(grid, 0, 0, 0)

      assert Grid.has_value?(grid, 0)
    end
  end

  describe "find_indexes/2" do
    test "returns all the positions in the grid that have a specific value" do
      grid = Grid.new(2, :v12)

      assert [] = Grid.find_indexes(grid, :v8)
      assert Enum.sort(Grid.find_indexes(grid, :v12)) == [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
    end
  end

end
