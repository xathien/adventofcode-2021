count = 0
desired_sizes = [2,3,4,7]
count = File.readlines('input')
    .reduce(0) do |sum, line|
      (left_side, right_side) = line.strip.split(' | ')
      sum + right_side.split(" ").filter { |segments| desired_sizes.include?(segments.size) }.count
    end

pp "Count: #{count}"