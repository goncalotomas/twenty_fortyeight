defmodule TwentyFortyeight.Game do
  @moduledoc """
  This is an implementation of the popular 2048 Game written by Gonçalo Tomás.
  For this particular implementation I had no other focus than to make something
  functional in the least amount of time possible, not taking any time to evaluate
  the efficiency of algorithms and the data structures used.
  My main concerns writing this implementation were:
  1) Making a version that worked more or less like the original 2048 game
  2) Having a somewhat clean abstraction on which to build the game
  3) Focus on making it work in a relatively short period of time (under 8 hours)

  A game is represented as a 2-tuple {game_status, game_grid}.
  The first element is the game state which can have 3 possible values:
  `:started`  - The game has been started and is ongoing
  `:lost`     - The game was lost, probably by running out of free tiles
  `:won`      - The game was won, the player reached the limit value

  Q: Why not a GenServer or gen_statem based solution?
  A: https://www.theerlangelist.com/article/spawn_or_not

  Unsupported cases:
  1) Continuing to play after reaching the limit value.
  """

  alias TwentyFortyeight.Grid

  @default_grid_size 6
  @new_tile_value 2
  @winning_value 2048

  def new(grid_size \\ @default_grid_size) do
    {
      :started,
      Grid.new(grid_size, 0) |> spawn_tile()
    }
  end

  @doc """
  Performs the game state update equivalent to a swipe up or an arrow-up event.
  Swipe up performs an update on the grid columns, merging from top to bottom.
  """
  def swipe_up({:started, grid}) do
    grid
    |> Grid.get_columns()
    |> Enum.map(&shift_and_merge_right/1)
    |> Enum.reduce_while({grid, 0}, fn updated_column, {grid, index} ->
      if index + 1 == length(grid) do
        {:halt, Grid.set_column(grid, index, updated_column)}
      else
        {:cont, {Grid.set_column(grid, index, updated_column), index + 1}}
      end
    end)
    |> maybe_spawn_tile(grid)
    |> check_grid()
  end

  @doc """
  Performs the game state update equivalent to a swipe down or an arrow-down event.
  Swipe down performs an update on the grid columns, merging from bottom to top.
  This is done using the same algorithm of `swipe_up/1`, reversing the list positions
  and shifting empty values left instead of right.
  """
  def swipe_down({:started, grid}) do
    grid
    |> Grid.get_columns()
    |> Enum.map(&shift_and_merge_left/1)
    |> Enum.reduce_while({grid, 0}, fn updated_column, {grid, index} ->
      if index + 1 == length(grid) do
        {:halt, Grid.set_column(grid, index, updated_column)}
      else
        {:cont, {Grid.set_column(grid, index, updated_column), index + 1}}
      end
    end)
    |> maybe_spawn_tile(grid)
    |> check_grid()
  end

  @doc """
  Performs the game state update equivalent to a swipe left or an arrow-left event.
  Swipe left performs an update on the grid lines, merging from left to right.
  """
  def swipe_left({:started, grid}) do
    grid
    |> Grid.get_lines()
    |> Enum.map(&shift_and_merge_right/1)
    |> Enum.reduce_while({grid, 0}, fn updated_line, {grid, index} ->
      if index + 1 == length(grid) do
        {:halt, Grid.set_line(grid, index, updated_line)}
      else
        {:cont, {Grid.set_line(grid, index, updated_line), index + 1}}
      end
    end)
    |> maybe_spawn_tile(grid)
    |> check_grid()
  end

  @doc """
  Performs the game state update equivalent to a swipe right or an arrow-right event.
  Swipe right performs an update on the grid lines, merging from right to left.
  This is done using the same algorithm of `swipe_left/1`, reversing the list positions
  and shifting empty values left instead of right.
  """
  def swipe_right({:started, grid}) do
    grid
    |> Grid.get_lines()
    |> Enum.map(&shift_and_merge_left/1)
    |> Enum.reduce_while({grid, 0}, fn updated_line, {grid, index} ->
      if index + 1 == length(grid) do
        {:halt, Grid.set_line(grid, index, updated_line)}
      else
        {:cont, {Grid.set_line(grid, index, updated_line), index + 1}}
      end
    end)
    |> maybe_spawn_tile(grid)
    |> check_grid()
  end

  defp check_grid(grid) do
    cond do
      length(Grid.find_indexes(grid, 0)) == 0 ->
        {:lost, grid}

      Grid.has_value?(grid, @winning_value) ->
        {:won, grid}

      true ->
        {:started, grid}
    end
  end

  # Sorts a list of numbers using the logic of the game.
  # The sort works by clearing empty space between the numbers
  # and merging equal numbers.
  defp shift_and_merge_right(list) do
    list
    |> shift_empties_right()
    |> merge_consecutive_equal_numbers()
    |> shift_empties_right()
  end

  defp shift_and_merge_left(list) do
    # we have to reverse list twice here
    # because the algorithm in merge_consecutive_equal_numbers
    # processes lists from left to right
    list
    |> Enum.reverse()
    |> shift_empties_right()
    |> merge_consecutive_equal_numbers()
    |> shift_empties_right()
    |> Enum.reverse()
  end

  defp shift_empties_right(list) do
    # sort list with custom sorter where we give more weight to zero (empty) values
    # so they end up in the end of the list
    Enum.sort_by(list, fn number ->
      if number != 0 do
        0
      else
        1
      end
    end)
  end

  defp merge_consecutive_equal_numbers(list) do
    merge_consecutive_equal_numbers_rec(list, {[], 0})
  end

  defp merge_consecutive_equal_numbers_rec([], {acc, merges}) do
    Enum.reverse(acc) ++ add_padding(merges)
  end

  defp merge_consecutive_equal_numbers_rec([n], {acc, merges}) do
    Enum.reverse([n | acc]) ++ add_padding(merges)
  end

  defp merge_consecutive_equal_numbers_rec([n, n | tail], {acc, merges}) when n != 0 do
    merge_consecutive_equal_numbers_rec(tail, {[n + n | acc], merges + 1})
  end

  defp merge_consecutive_equal_numbers_rec([n1, n2 | tail], {acc, merges}) do
    merge_consecutive_equal_numbers_rec([n2 | tail], {[n1 | acc], merges})
  end

  defp add_padding(merges) do
    add_padding([], merges)
  end

  defp add_padding(acc, 0) do
    acc
  end

  defp add_padding(acc, merges) do
    add_padding([0 | acc], merges - 1)
  end

  defp maybe_spawn_tile(new_grid, old_grid) do
    if new_grid != old_grid do
      spawn_tile(new_grid)
    else
      # prevent players from losing quickly!
      # if there was no change in the grid, don't spawn a new tile.
      # this gives the player a hint that the right thing to do
      # might be to swipe in a different direction.
      new_grid
    end
  end

  defp spawn_tile(grid) do
    {line, column} =
      grid
      |> Grid.find_indexes(0)
      |> Enum.random()

    Grid.put(grid, line, column, @new_tile_value)
  end
end
