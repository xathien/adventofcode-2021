require "set"

@octopodes = File.readlines('input')
    .map do |line|
      line = line.strip.split("").map(&:to_i)
      line
    end

@to_flash = []
@max_rows = @octopodes.size - 1
@max_cols = @octopodes.size - 1

def visit(row, col)
  octopus = @octopodes[row][col] += 1
  if octopus == 10
    @to_flash << [row, col]
    (row-1..row+1).each { |next_row|
      next if next_row < 0 || next_row > @max_rows
      (col-1..col+1).each { |next_col|
        next if next_col < 0 || next_col > @max_cols
        visit(next_row, next_col)
      }
    }
  end
end

total_flashes = 0
(1..100).each { |round|
  (0..@max_rows).each { |row|
    (0..@max_cols).each { |col|
      visit(row, col)
    }
  }

  total_flashes += @to_flash.size
  @to_flash.each { |row, col|
    @octopodes[row][col] = 0
  }
  @to_flash = []
}

pp "Flashes: #{total_flashes}"