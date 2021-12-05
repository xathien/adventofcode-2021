grid = Hash.new { |h, k| h[k] = Hash.new(0) }

File.readlines('input')
    .map do |line|
      (start_row, start_col, end_row, end_col) = line.strip.split(' -> ').flat_map { |coord| coord.split(',').map(&:to_i) }
      if start_row == end_row
        end_col, start_col = start_col, end_col if start_col > end_col
        row = grid[start_row]
        (start_col..end_col).each { |col| row[col] += 1 }
      elsif start_col == end_col
        end_row, start_row = start_row, end_row if start_row > end_row
        (start_row..end_row).each { |row| grid[row][start_col] += 1 }
      else
        # pp "Diagonal line! #{start_row}, #{start_col} -> #{end_row}, #{end_col}"
      end
    end

crosses = 0
grid.values.each do |row|
  row.values.each { |vents| crosses += 1 if vents > 1 }
end

pp "Crosses: #{crosses}"
