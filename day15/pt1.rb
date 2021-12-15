require 'set'

grid = File.readlines('input')
           .map do |line|
  line.strip.split('').map(&:to_i)
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

  until next_coords.empty?
    current = next_coord(next_coords, f_score)

    return assemble_path(path, current) if current == end_node

    next_coords.delete(current)

    neighbors(current, grid).each do |neighbor|
      tentative_g_score = g_score[current] + neighbor[2]
      next unless tentative_g_score < g_score[neighbor]

      path[neighbor] = current
      g_score[neighbor] = tentative_g_score
      f_score[neighbor] = tentative_g_score + max_distance - neighbor[0] - neighbor[1]
      next_coords << neighbor
    end
  end

  pp 'Uh... wtf'
end

finished_path = a_star(grid)
pp "Finished path: #{finished_path}"
danger_sum = finished_path.sum { |node| node[2] }

pp "Danger: #{danger_sum}"
