fish = {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
new_fish = {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
ready_fish = {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}

File.readlines('input')
    .each do |line|
      line.strip.split(',').each { |timer| fish[timer.to_i] += 1 }
    end

(0..255).each do |day|
  cycle_day = day % 7
  fish[cycle_day] += ready_fish[cycle_day]
  ready_fish[cycle_day] = new_fish[cycle_day]
  new_fish[cycle_day] = 0
  new_cycle_day = (cycle_day + 2) % 7
  new_fish[new_cycle_day] = fish[cycle_day]
end

fish_count = fish.values.inject(0) { |v, s| s + v }
ready_fish_count = ready_fish.values.inject(0) { |v, s| s + v }
new_fish_count = new_fish.values.inject(0) { |v, s| s + v }
total = fish_count + ready_fish_count + new_fish_count

pp "Fsh: #{fish_count} + #{ready_fish_count} + #{new_fish_count} = #{total}"
