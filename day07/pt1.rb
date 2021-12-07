positions = File.readlines('input')
    .flat_map do |line|
      line.strip.split(',').map(&:to_i).sort
    end

lowest_fuel = 371375
(0..1919).each { |target|
  fuel = positions.reduce(0) { |sum, position|
     sum + (position - target).abs
    }
  if fuel < lowest_fuel
    pp "Better alignment: #{target} uses #{fuel}"
    lowest_fuel = fuel
  end
}
