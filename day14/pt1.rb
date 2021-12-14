require 'set'

polymer = nil

File.readlines('input')
    .each do |line|
      polymer = line.strip.split('')
    end

meld = {}

File.readlines('input_instr')
    .each do |line|
      input, output = line.strip.split(' -> ')
      meld[input] = output
    end

(1..10).each { |_|
  new_polymer = []
  polymer.each_with_index { |first_input, index|
    new_polymer[2 * index] = first_input
    second_input = polymer[index + 1]
    next if second_input.nil?
    new_polymer[2 * index + 1] = meld[first_input + second_input]
  }
  polymer = new_polymer
}

instances = Hash.new(0)
polymer.each { |value| instances[value] += 1 }
sorted_instances = instances.values.sort

pp "Total Counts: #{instances}"
pp "Diff: #{sorted_instances.last - sorted_instances.first}"
