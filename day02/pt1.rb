depth = 0
distance = 0
File.readlines('input')
    .map do |line|
  (direction, amount) = line.split
  amount = amount.to_i
  case direction
  when 'forward'
    distance += amount
  when 'down'
    depth += amount
  when 'up'
    depth -= amount
  end
end

pp "Depth: #{depth} - Forward #{distance} - Product: #{depth * distance}"
