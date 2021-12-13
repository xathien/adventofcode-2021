require 'set'

graph = Array.new(895) { Array.new(1309) }

File.readlines('input')
    .each do |line|
      col, row = line.strip.split(',').map(&:to_i)
      graph[row][col] = 1
    end

instructions = File.readlines('input_instr')
    .map do |line|
      line.strip.split(' ')[2].split("=")
    end

instructions.take(1).each { |axis, index|
  index = index.to_i
  if axis == "x"
    graph.each { |row|
      right_side = row.slice!(index..)
      right_side.drop(1).each_with_index { |value, i|
        row[-(i + 1)] ||= value
      }
    }
  else
    graph.take(index).each_with_index { |upper_row, i|
      lower_row = graph[-(i + 1)]
      lower_row.each_with_index { |lower_value, j| upper_row[j] ||= lower_value }
    }
    graph.slice!(index..)
  end
}

dots_visible = graph.reduce(0) { |sum, row| sum + row.compact.sum }

pp "Dots? #{dots_visible}"
