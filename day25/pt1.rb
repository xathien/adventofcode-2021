require 'set'
require 'json'

grid = File.readlines('input')
    .map do |line|
      line.strip.split("").map { |val| [val, 0]}
    end

@max_row = grid.size - 1
@max_col = grid[0].size - 1

def move_e(row, col, grid, turn)
  grid_row = grid[row]
  spot, last_modified = grid_row[col]
  return 0 if last_modified == turn # This spot has already moved this turn
  case spot
  when ">"
    tar_col = col == @max_col ? 0 : col + 1
    # pp "> can move to #{row}, #{col} => #{tar_col} ? #{grid_row[tar_col]}"
    tar_spot, last_modified = grid_row[tar_col]
    if tar_spot == "." && last_modified < turn
      grid_row[tar_col] = [">", turn]
      grid_row[col] = [".", turn]
      1
    else
      0
    end
  else
    0
  end
end

def move_s(row, col, grid, turn)
  grid_row = grid[row]
  spot, last_modified = grid_row[col]
  return 0 if last_modified == turn # This spot has already moved this turn
  case spot
  when "v"
    tar_row = row == @max_row ? 0 : row + 1
    grid_tar_row = grid[tar_row]

    # pp "Wut: #{row}, #{col}, #{tar_row}"
    tar_spot, last_modified = grid_tar_row[col]
    if tar_spot == "."

      if last_modified == turn
        # Something just moved out of this space. It's fine, iff it was a >
        check_col = col == @max_col ? 0 : col + 1
        check_spot, last_modified = grid_tar_row[check_col]
        return 0 if check_spot != ">" || last_modified < turn
      end
      # pp "I can move to #{tar_row}, #{col}"
      grid_tar_row[col] = ["v", turn]
      grid_row[col] = [".", turn]
      1
    else
      0
    end
  else
    0
  end
end

pp "Initial state:"
grid.each { |row|
  p row.map { |val, _last_modified| val }.join("")
}

move_count = -1
step_count = 0
until move_count == 0
  step_count += 1
  move_count = (0..@max_row).reduce(0) { |row_move_count, row|
    row_move_count + (0..@max_col).reduce(0) { |col_move_count, col|
      col_move_count + move_e(row, col, grid, step_count)
    }
  }
  # pp "After step #{step_count} part 1:"
  # grid.each { |row|
  #   p row.map { |val, _last_modified| val }.join("")
  # }
  move_count += (0..@max_row).reduce(0) { |row_move_count, row|
    row_move_count + (0..@max_col).reduce(0) { |col_move_count, col|
      col_move_count + move_s(row, col, grid, step_count)
    }
  }
  # pp "After step #{step_count} part 2:"
  # grid.each { |row|
  #   p row.map { |val, _last_modified| val }.join("")
  # }
end

pp "Step #{step_count} had #{move_count} moves!"