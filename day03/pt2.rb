g_candidates = []
e_candidates = []
File.readlines('input')
    .map do |line|
      g_candidates << line.strip
      e_candidates << line.strip
    end

index = 0
while g_candidates.size > 1
  pp "Starting index #{index}"
  zeros = 0
  ones = 0
  g_candidates.each { |cand|
    if cand[index] == "0"
      zeros += 1
    else
      ones += 1
    end
  }

  most_common = ones >= zeros ? "1" : "0"
  pp "G most common #{most_common}"
  g_candidates.filter! { |cand|
    pp "#{cand} - #{cand[index] == most_common}"
    cand[index] == most_common
  }
  index += 1
end

index = 0
while e_candidates.size > 1
  zeros = 0
  ones = 0

  e_candidates.each { |cand|
    if cand[index] == "0"
      zeros += 1
    else
      ones += 1
    end
  }

  pp "Zeroes #{zeros} - Ones #{ones}"

  least_common = zeros <= ones ? "0" : "1"
  pp "E least common[#{index}] #{least_common}"
  e_candidates.filter! { |cand|
    pp "#{cand} - #{cand[index] == least_common}"
    cand[index] == least_common
  }
  index += 1
end

o2_num = g_candidates[0].to_i(2)
co2_num = e_candidates[0].to_i(2)
pp "O2: #{o2_num} - CO2: #{co2_num}"

pp o2_num * co2_num