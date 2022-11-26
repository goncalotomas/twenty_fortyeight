defmodule TwentyFortyeight.Grid do
  @moduledoc """
  Defines an abstraction for a square grid.
  No assumptions are made about the type of values that are stored.
  It is implemented naively as list of lists, but a more complex
  implementation such as the Erlang :array module could be used
  if the behavior of this module and its callbacks are maintained.
  """

  @doc """
  Returns a new Grid with a certain size, initializing all positions
  with a specified initial value.
  """
  def new(size, initial_value) do
    Enum.map(1..size, fn _ ->
      Enum.map(1..size, fn _ -> initial_value end)
    end)
  end

  @doc """
  Returns the element in the grid at a certain (zero-index) line and column number
  """
  def get(grid, line, column) do
    grid
    |> Enum.at(line)
    |> Enum.at(column)
  end

  @doc """
  Updates a certain position in a grid identified by a (zero-index) line and column number
  """
  def put(grid, line, column, value) do
    new_line =
      grid
      |> Enum.at(line)
      |> List.replace_at(column, value)

    grid
    |> List.replace_at(line, new_line)
  end

  @doc """
  Checks whether a grid has any positions with a certain value.
  Returns `true` if at least one position has the specified value and `false` otherwise.
  """
  def has_value?(grid, value) do
    Enum.reduce_while(grid, false, fn line, acc ->
      if Enum.member?(line, value) do
        {:halt, true}
      else
        {:cont, acc}
      end
    end)
  end

  @doc """
  Returns a list of indexes in the form of {line, column} for all elements
  in a grid that have a certain value.
  The values returned for line and column can be used as arguments to the
  `get/3` and `put/4` functions.
  """
  def find_indexes(grid, value) do
    grid_size = length(grid)

    Enum.reduce(0..(grid_size - 1), [], fn line, line_acc ->
      [
        Enum.reduce(0..(grid_size - 1), [], fn column, col_acc ->
          slot_value =
            grid
            |> Enum.at(line)
            |> Enum.at(column)

          if slot_value == value do
            [{line, column} | col_acc]
          else
            col_acc
          end
        end)
        | line_acc
      ]
    end)
    |> List.flatten()
  end

  def get_lines(grid) do
    grid
  end

  def set_line(grid, line, values) do
    List.replace_at(grid, line, values)
  end

  def get_columns(grid) do
    Enum.map(0..(length(grid) - 1), fn index ->
      Enum.map(grid, fn line -> Enum.at(line, index) end)
    end)
  end

  def set_column(grid, column, values) do
    Enum.map(0..(length(grid) - 1), fn index ->
      List.replace_at(Enum.at(grid, index), column, Enum.at(values, index))
    end)
  end
end
