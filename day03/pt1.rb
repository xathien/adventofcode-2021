zero_counts = Array.new(12, 0)
one_counts = Array.new(12, 1)
File.readlines('input')
    .map do |line|
      pp line
      line.strip.split("").each_with_index { |char, index|
        pp char
        if char == "0"
          zero_counts[index] += 1
        else
          one_counts[index] += 1
        end
      }
    end

gamma = ""
epsilon = ""
zero_counts.zip(one_counts).each { |zero_count, one_count|
  if zero_count >= one_count
    gamma << "0"
    epsilon << "1"
  else
    gamma << "1"
    epsilon << "0"
  end
}

pp "Gamma: #{gamma} - Eps: #{epsilon}"

gamma_num = gamma.to_i(2)
eps_num = epsilon.to_i(2)

pp gamma_num * eps_num