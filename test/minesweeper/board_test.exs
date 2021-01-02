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

  test "swipe test" do
    board = Board.new(4, 4, 2, @rnd_seed)

    # The generated board used along this test is the following

    # |   |   | * |   |
    # |   |   |   |   |
    # |   |   |   |   |
    # |   |   | * |   |

    # Mines at (0, 2) and (3, 2)

    # Swiping a cell outside board dimensions fails
    assert_raise(RuntimeError, "Invalid cell", fn -> Board.swipe(board, 100, 100) end)

    # Swiping a cleared cell does nothing
    assert board |> Board.swipe(0, 0) == board |> Board.swipe(0, 0) |> Board.swipe(1, 0)

    # Swiping a flagged cell does nothing
    assert board |> Board.flag(0, 0) == board |> Board.flag(0, 0) |> Board.swipe(0, 0)

    # Swiping a marked cell ignores the mark and swipes
    assert board |> Board.swipe(0, 0) == board |> Board.mark(0, 0) |> Board.swipe(0, 0)

    # Swiping a cell with no mines around propagates removing flags and marks
    assert board
           |> Board.flag(0, 0)
           |> Board.mark(1, 0)
           |> Board.swipe(2, 0) == board |> Board.swipe(2, 0)

    # Swipe propagation skips cells with mines
    refute board
           |> Board.swipe(0, 0)
           |> Board.get_cell(0, 2)
           |> Board.Cell.cleared?()

    refute board
           |> Board.swipe(0, 0)
           |> Board.get_cell(3, 2)
           |> Board.Cell.cleared?()

    # Swiping a cell with a mine does not propagate swipe
    swiped_mine_board = board |> Board.swipe(0, 2)

    for i <- 0..(board.rows - 1), j <- 0..(board.cols - 1) do
      if i != 0 and j != 2 do
        assert swiped_mine_board |> Board.get_cell(i, j) |> Board.Cell.unexplored?()
      end
    end
  end

  test "decide test" do
    board = Board.new(4, 4, 2, @rnd_seed)

    # The generated board used along this test is the following

    # |   |   | * |   |
    # |   |   |   |   |
    # |   |   |   |   |
    # |   |   | * |   |

    # Mines at (0, 2) and (3, 2)

    # Game is lost after swiping a mine
    assert board |> Board.swipe(0, 2) |> Board.decide() == :lost

    # Game is won after flagging all mines
    assert board |> Board.flag(0, 2) |> Board.flag(3, 2) |> Board.decide() == :won

    # Game is undecided if any mine remains to be flagged
    assert board |> Board.flag(0, 2) |> Board.decide() == :undecided
  end
end
