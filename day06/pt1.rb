fish = []

class Fish

  def initialize(timer)
  @timer = timer
  end

  def dec(fish)
    @timer -= 1
    if @timer < 0
      @timer = 6
      fish << Fish.new(9)
    end
  end

  def inspect
    @timer.to_s
  end
end

File.readlines('input')
    .each do |line|
      line.strip.split(',').each { |timer| fish << Fish.new(timer.to_i) }
    end

(1..80).each do |day|
  old_size = fish.size
  fish.each { |fsh| fsh.dec(fish) }
  pp "Day #{day - 1} - spawned #{fish.size - old_size}, Total: #{fish.size}"
end

pp "Fsh: #{fish.size}"
