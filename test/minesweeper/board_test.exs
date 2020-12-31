defmodule Minesweeper.BoardTest do
  use ExUnit.Case

  alias Minesweeper.Board

  @moduletag :capture_log
  @rnd_seed {1, 2, 3}
  #  doctest Board

  test "module exists" do
    assert is_list(Board.module_info())
  end

  test "create new board" do
    board = Board.new(10, 20, 50, @rnd_seed)
    assert board.rows == 10
    assert board.cols == 20
    assert Enum.count(board.cells) == 200
    assert Enum.count(board.cells, &Board.Cell.mine?/1) == 50
    assert Enum.all?(board.cells, &Board.Cell.unexplored?/1)
  end

  test "mark a cell" do
    board = Board.new(10, 20, 50, @rnd_seed)
    updated_board = Board.mark(board, 5, 5)
    market_cell = Board.get_cell(updated_board, 5, 5)
    assert Board.Cell.marked?(market_cell)
  end

end
