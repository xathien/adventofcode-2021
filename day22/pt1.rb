require 'set'
require 'json'

grid = Hash.new(0)

File.readlines('input')
    .each do |line|
      command, ranges = line.strip.split(" ")
      value = command == "on" ? 1 : 0
      x_r, y_r, z_r = ranges.split(",").map { |range| Range.new(*range.split("..").map(&:to_i)) }
      x_r.each { |x|
        next if x < 0 || x > 100
        y_r.each { |y|
          next if y < 0 || y > 100
          z_r.each { |z|
            next if z < 0 || z > 100
            grid[[x, y, z]] = value
          }
        }
      }
    end

cubes_on = grid.values.sum
pp "Result: #{cubes_on}"