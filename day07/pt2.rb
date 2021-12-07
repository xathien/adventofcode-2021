positions = File.readlines('input')
                .flat_map do |line|
  line.strip.split(',').map(&:to_i).sort
end

lowest_fuel = 99_999_999
(0..1919).each do |target|
  fuel = positions.reduce(0) do |sum, position|
    distance = (position - target).abs
    this_fuel = distance * (distance + 1) / 2
    sum + this_fuel
  end
  if fuel < lowest_fuel
    pp "Better alignment: #{target} uses #{fuel}"
    lowest_fuel = fuel
  end
end
