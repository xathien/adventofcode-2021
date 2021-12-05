grid = Hash.new { |h, k| h[k] = Hash.new(0) }

File.readlines('input')
    .map do |line|
      (start_row, start_col, end_row, end_col) = line.strip.split(' -> ').flat_map { |coord| coord.split(',').map(&:to_i) }
      r_step = end_row > start_row ? 1 : -1
      c_step = end_col > start_col ? 1 : -1
      if start_row == end_row
        row = grid[start_row]
        (start_col..end_col).step(c_step).each { |col| row[col] += 1 }
      elsif start_col == end_col
        (start_row..end_row).step(r_step).each { |row| grid[row][start_col] += 1 }
      else
        row_r = (start_row..end_row).step(r_step)
        col_r = (start_col..end_col).step(c_step)
        row_r.zip(col_r).each { |row, col| grid[row][col] += 1; }
      end
    end

crosses = 0
grid.values.each do |row|
  row.values.each { |vents| crosses += 1 if vents > 1 }
end

pp "Crosses: #{crosses}"