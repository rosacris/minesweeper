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

  test "get a cell" do
    board = Board.new(10, 20, 50, @rnd_seed)
    cell = Board.get_cell(board, 5, 10)

    assert {5, 10, :mine, :unexplored} = cell
    assert_raise(RuntimeError, "Invalid cell", fn -> Board.get_cell(board, 100, 100) end)
  end

  test "mark a cell" do
    board = Board.new(10, 20, 50, @rnd_seed)

    # Cell outside board dimensions fail
    assert_raise(RuntimeError, "Invalid cell", fn -> Board.mark(board, 100, 100) end)

    # One mark set the cell as marked
    assert board
           |> Board.mark(5, 5)
           |> Board.get_cell(5, 5)
           |> Board.Cell.marked?()

    # Two marks in the same cell removes the mark
    refute board
           |> Board.mark(1, 2)
           |> Board.mark(1, 2)
           |> Board.get_cell(1, 2)
           |> Board.Cell.marked?()
  end

  test "flag a cell" do
    board = Board.new(10, 20, 50, @rnd_seed)

    # Cell outside board dimensions fails
    assert_raise(RuntimeError, "Invalid cell", fn -> Board.flag(board, 100, 100) end)

    # One mark set the cell as flagged
    assert board
           |> Board.flag(5, 5)
           |> Board.get_cell(5, 5)
           |> Board.Cell.flagged?()

    # Two marks in the same cell removes the flag
    refute board
           |> Board.flag(1, 2)
           |> Board.flag(1, 2)
           |> Board.get_cell(1, 2)
           |> Board.Cell.flagged?()
  end
end
