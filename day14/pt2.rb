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

@instances = Hash.new(0)
@counter = 0
@memo = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Hash.new(0) } }

def recurse(left, right, iterations_left)
  pair = left + right
  memo = @memo.dig(pair, iterations_left)
  unless memo.empty?
    @memo_skip_count += 2**iterations_left
    return memo
  end

  memo_hash = @memo[pair][iterations_left]
  new_value = @meld[pair]

  if iterations_left == 1
    memo_hash[left] += 1
    memo_hash[right] += 1
    memo_hash[new_value] += 1
    return memo_hash
  end

  left_counts = recurse(left, new_value, iterations_left - 1)
  right_counts = recurse(new_value, right, iterations_left - 1)

  left_counts.each { |letter, count|
    memo_hash[letter] += count
  }
  right_counts.each { |letter, count|
    memo_hash[letter] += count
  }

  # Deduplicate the shared letter
  memo_hash[new_value] -= 1

  return memo_hash
end

polymer.take(polymer.size - 1).each_with_index { |left, index|
  right = polymer[index + 1]
  counts = recurse(left, right, 40)
  counts.each { |letter, count| @instances[letter] += count }
  # Deduplicate shared letters
  @instances[right] -= 1
}
# Put the last letter back on. It deserves to still be here.
@instances[polymer.last] += 1

pp "Total counts: #{@instances}"

pp "Skipped iterations: #{@memo_skip_count}"

sorted_instances = @instances.values.sort
pp "Diff: #{sorted_instances.last - sorted_instances.first}"
