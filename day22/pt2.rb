require 'set'
require 'json'

def intersects(r1, r2)
  (r1.begin <= r2.begin && r2.begin <= r1.end) || (r2.begin <= r1.begin && r1.begin <= r2.end)
end

@ranges = []

def add_range(ranges, drop = 0)
  x_r, y_r, z_r = ranges
  return if x_r.size == 0 || y_r.size == 0 || z_r.size == 0

  @ranges.drop(drop).each_with_index { |(x0_r, y0_r, z0_r), index|
    if intersects(x0_r, x_r) && intersects(y0_r, y_r) && intersects(z0_r, z_r)
      new_drop = drop + index + 1
      # Carve off the intersecting bits and try again
      left_xr = (x_r.begin..x0_r.begin - 1)
      add_range([left_xr, y_r, z_r], new_drop)
      right_xr = (x0_r.end + 1..x_r.end)
      add_range([right_xr, y_r, z_r], new_drop)
      mid_xr = ([x_r.begin, x0_r.begin].max..[x_r.end, x0_r.end].min)
      left_yr = (y_r.begin..y0_r.begin - 1)
      add_range([mid_xr, left_yr, z_r], new_drop)
      right_yr = (y0_r.end + 1..y_r.end)
      add_range([mid_xr, right_yr, z_r], new_drop)
      mid_yr = ([y_r.begin, y0_r.begin].max..[y_r.end, y0_r.end].min)
      left_zr = (z_r.begin..z0_r.begin - 1)
      add_range([mid_xr, mid_yr, left_zr], new_drop)
      right_zr = (z0_r.end + 1..z_r.end)
      add_range([mid_xr, mid_yr, right_zr], new_drop)
      return
    end
  }
  @ranges << ranges
end

def subtract_range(ranges)
  x_r, y_r, z_r = ranges
  return if x_r.size == 0 || y_r.size == 0 || z_r.size == 0

  ranges_to_add = []
  before = @ranges.size
  @ranges.delete_if { |x0_r, y0_r, z0_r|
    if intersects(x0_r, x_r) && intersects(y0_r, y_r) && intersects(z0_r, z_r)
      left_xr = (x0_r.begin..x_r.begin - 1)
      ranges_to_add << [left_xr, y0_r, z0_r]
      right_xr = (x_r.end + 1..x0_r.end)
      ranges_to_add << [right_xr, y0_r, z0_r]
      mid_xr = ([x_r.begin, x0_r.begin].max..[x_r.end, x0_r.end].min)
      left_yr = (y0_r.begin..y_r.begin - 1)
      ranges_to_add << [mid_xr, left_yr, z0_r]
      right_yr = (y_r.end + 1..y0_r.end)
      ranges_to_add << [mid_xr, right_yr, z0_r]
      mid_yr = ([y_r.begin, y0_r.begin].max..[y_r.end, y0_r.end].min)
      left_zr = (z0_r.begin..z_r.begin - 1)
      ranges_to_add << [mid_xr, mid_yr, left_zr]
      right_zr = (z_r.end + 1..z0_r.end)
      ranges_to_add << [mid_xr, mid_yr, right_zr]
      true
    else
      false
    end
  }

  # We know these ranges are all unique from the others, but they'll collide with each other, so only check uniqueness there
  after = @ranges.size
  ranges_to_add.each { |range| add_range(range, after) }
end

File.readlines('input')
    .each do |line|
      command, ranges = line.strip.split(" ")
      parsed_ranges = ranges.split(",").map { |range| Range.new(*range.split("..").map(&:to_i)) }
      if command == "on"
        add_range(parsed_ranges)
      else
        subtract_range(parsed_ranges)
      end
    end

cubes_on = @ranges.reduce(0) { |sum, (x_r, y_r, z_r)|
  sum + (x_r.size * y_r.size * z_r.size)
}
pp "Result: #{cubes_on}"