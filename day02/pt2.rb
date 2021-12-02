depth = 0
distance = 0
aim = 0
File.readlines('input')
    .map do |line|
  (direction, amount) = line.split
  amount = amount.to_i
  case direction
  when 'forward'
    distance += amount
    depth += aim * amount
  when 'down'
    aim += amount
  when 'up'
    aim -= amount
  end
end

pp "Depth: #{depth} - Forward #{distance} - Product: #{depth * distance}"
