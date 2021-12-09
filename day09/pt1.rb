require "set"

@area = File.readlines('input')
    .map do |line|
      line.strip.split("").map(&:to_i)
    end

@visited = Set.new([[0, 0]])
@max_col = @area[0].size - 1
@max_row = @area.size - 1
@low_points = []

def follow_to_low_point(coords)
  return if @visited.include?(coords)

  current_coords = coords
  next_coords = nil
  found_low_point = false
  until found_low_point
    next_coords = pick_direction(current_coords)
    found_low_point = next_coords == current_coords
    break if @visited.include?(next_coords)
    @visited << next_coords
    current_coords = next_coords
  end
  @low_points << @area.dig(*current_coords) + 1 if found_low_point
  pp "Overlap detected" unless found_low_point
  pp "Low point found at #{current_coords} - #{@area.dig(*current_coords)}" if found_low_point
end

def pick_direction(coords)
  row, col = coords
  current_depth = @area.dig(row, col)
  potential_coords = [
    [col > 0 ? @area.dig(row, col - 1) : 10, row, col - 1], # Left
    [col < @max_col ? @area.dig(row, col + 1) : 10, row, col + 1], # Right
    [row > 0 ? @area.dig(row - 1, col) : 10, row - 1, col], # Up
    [row < @max_row ? @area.dig(row + 1, col) : 10, row + 1, col], # Down
  ]

  pp "Potential coords: #{potential_coords} - Current #{current_depth}"

  lowest_neighbor = potential_coords.min_by { |tuple| tuple[0] }
  current_depth < lowest_neighbor[0] ? coords : lowest_neighbor.slice(1, 2)
end

(0..@max_row).each { |row_index|
  (0..@max_row).each { |col_index|
    follow_to_low_point([row_index, col_index])
  }
}

low_point_danger_sum = @low_points.sum
pp "Danger: #{low_point_danger_sum}"