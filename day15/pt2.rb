require 'set'

start_grid = File.readlines('input')
                 .map do |line|
  line.strip.split('').map(&:to_i)
end

grid = Array.new(start_grid.size * 5) { Array.new(start_grid.size * 5, 0) }
size = start_grid.size
pp "How big is it? #{grid.size}"

start_grid.each_with_index do |row, row_i|
  row.each_with_index do |value, col_i|
    (0..4).each do |row_mult|
      row_offset = size * row_mult
      target_row = grid[row_i + row_offset]
      (0..4).each do |col_mult|
        col_offset = size * col_mult
        new_val = (value + row_mult + col_mult)
        new_val = (new_val % 10) + 1 if new_val > 9
        target_row[col_i + col_offset] = new_val
      end
    end
  end
end

def next_coord(coord_set, f_score)
  coord_set.min_by { |node| f_score[node] } # Ewww, it's O(n) :(
end

def assemble_path(path, current)
  full_path = [current]
  while path.key?(current)
    current = path[current]
    full_path << current
  end
  full_path.reverse
end

NEIGHBORS = [[0, 1], [0, -1], [1, 0], [-1, 0]].freeze
def neighbors(node, grid)
  max_index = grid.size - 1
  neighbors = []
  row, col, = node
  NEIGHBORS.map do |row_diff, col_diff|
    new_row = row + row_diff
    new_col = col + col_diff
    [new_row, new_col, grid.dig(new_row, new_col)]
  end
           .filter { |new_row, new_col, _| new_row >= 0 && new_row <= max_index && new_col >= 0 && new_col <= max_index }
end

def a_star(grid)
  max_distance = grid.size + grid[0].size
  max_index = grid.size - 1

  path = {}

  # y, x, risk
  start_node = [0, 0, 0]
  end_node = [max_index, max_index, grid[max_index][max_index]]

  # Life would be better if this were a priority queue
  next_coords = Set.new([start_node])

  g_score = Hash.new(Float::INFINITY)
  g_score[start_node] = 0

  f_score = Hash.new(Float::INFINITY)
  f_score[start_node] = max_distance

  closest_distance = max_distance

  until next_coords.empty?
    current = next_coord(next_coords, f_score)

    return assemble_path(path, current) if current == end_node

    next_coords.delete(current)

    neighbors(current, grid).each do |neighbor|
      tentative_g_score = g_score[current] + neighbor[2]
      next unless tentative_g_score < g_score[neighbor]

      path[neighbor] = current
      g_score[neighbor] = tentative_g_score
      distance = max_distance - neighbor[0] - neighbor[1]
      f_score[neighbor] = tentative_g_score + distance
      if distance < closest_distance
        pp "Closer: #{distance}"
        closest_distance = distance
      end
      next_coords << neighbor
    end
  end

  pp 'Uh... wtf'
end

finished_path = a_star(grid)
pp "Finished path: #{finished_path}"
danger_sum = finished_path.sum { |node| node[2] }

pp "Danger: #{danger_sum}"
