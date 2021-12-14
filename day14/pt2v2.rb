require 'set'

polymer = nil

File.readlines('input')
    .each do |line|
      polymer = line.strip.split('')
    end

@meld = {}

File.readlines('input_instr')
    .each do |line|
      input, output = line.strip.split(' -> ')
      @meld[input] = output
    end

polymer << "!"
pairs = Hash.new(0)

polymer.take(polymer.size - 1).each_with_index { |left, index|
  right = polymer[index + 1]
  pair = left + right
  pairs[pair] += 1
}

(1..40).each { |_|
  new_pairs = Hash.new(0)
  pairs.each { |pair, count|
    new_char = @meld[pair]
    if new_char.nil? # Far right of polymer
      new_pairs[pair] = 1
      next
    end

    new_pairs[new_char + pair[1]] += count
    new_pairs[pair[0] + new_char] += count
  }
  pairs = new_pairs
}

counts = Hash.new(0)
pairs.each { |pair, count|
  counts[pair[0]] += count
}

pp "Total counts: #{counts}"

sorted_instances = counts.values.sort
pp "Diff: #{sorted_instances.last - sorted_instances.first}"
