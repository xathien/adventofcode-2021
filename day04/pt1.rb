class Board
  def initialize
    @coords = {}
    @numbers = Array.new(5) { Array.new(5, 0) }
    @marked = Array.new(5) { Array.new(5, false) }
    @number_count = 0
  end

  def add(number)
    row = @number_count / 5
    column = @number_count % 5
    @numbers[row][column] = number
    @coords[number] = [row, column]
    @number_count += 1
  end

  def full?
    @number_count == 25
  end

  def mark(number)
    (row, column) = @coords[number]
    pp "Coords: #{row}, #{column}"
    @marked[row][column] = true
    row_finished = (0..4).all? { |i_col| @marked[row][i_col] }
    pp "Is the row finished? #{row_finished}"
    return true if row_finished
    col_finished = (0..4).all? { |i_row| @marked[i_row][column] }
  end

  def score
    score = 0
    (0..4).each do |row|
      (0..4).each do |column|
        number = @numbers[row][column]
        score += number unless @marked[row][column]
      end
    end
    score
  end
end

boards = []
board_indexes = Hash.new { |h, k| h[k] = [] }
called_numbers = []
File.readlines('input')
    .map do |line|
      called_numbers = line.strip.split(',').map(&:to_i)
    end

board = Board.new
File.readlines('input_boards')
.map do |row|
  row.strip.split(" ").map(&:to_i).each { |number|
    board.add number
    board_indexes[number] << board
  }
  if board.full?
    boards << board
    board = Board.new
  end
end

pp "Boards? #{boards.size}"

called_numbers.each { |called_number|
  pp "Calling #{called_number}!"
  board_indexes[called_number].each { |board|
    board_won = board.mark(called_number)
    if board_won
      score = board.score
      pp "Board won! #{called_number} * #{score} = #{called_number * score}"
      return
    end
  }
}
