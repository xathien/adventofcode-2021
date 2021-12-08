require "set"

count = 0
desired_sizes = [2,3,4,7]
patterns = {
  [1, 1, 1, 0, 1, 1, 1] => 0,
  [0, 0, 1, 0, 0, 1, 0] => 1,
  [1, 0, 1, 1, 1, 0, 1] => 2,
  [1, 0, 1, 1, 0, 1, 1] => 3,
  [0, 1, 1, 1, 0, 1, 0] => 4,
  [1, 1, 0, 1, 0, 1, 1] => 5,
  [1, 1, 0, 1, 1, 1, 1] => 6,
  [1, 0, 1, 0, 0, 1, 0] => 7,
  [1, 1, 1, 1, 1, 1, 1] => 8,
  [1, 1, 1, 1, 0, 1, 1] => 9,
}

def letter_to_num(letter)

end

total_sum = File.readlines('input')
    .reduce(0) do |sum, line|
      (left_side, right_side) = line.strip.split(' | ')

      # Orders array by: [1, 7, 4, (2,3,5), (0,6,9), 8]
      digits = left_side.split(" ").sort_by(&:length)

      # Narrow down segments 2 and 5
      one_segments = digits[0].split("").to_set

      # 7 uses 0, 2, 5, so we can determine which one is segment 0
      seven_segments = digits[1].split("").to_set
      segment_zero = (seven_segments - one_segments)

      # 4 uses 1, 2, 3, 5, so we can reduce 1 and 3
      four_segments = digits[2].split("").to_set
      segments_one_three = four_segments - one_segments

      # We can find 3 by seeing which 5-segment number contains all of seven_segments
      two_or_five_index = Set.new([3,4,5])
      three_segments_index = (3..5).find { |possible| (seven_segments - digits[possible].split("").to_set).empty? }
      two_or_five_index.delete(three_segments_index)
      three_segments = digits[three_segments_index].split("").to_set
      segments_three_six = three_segments - seven_segments

      # 3's segments minus 4's segments will get us Segment 6, which leads directly to Segment 3
      segment_six = segments_three_six - four_segments
      segment_three = segments_three_six - segment_six

      # 4's segments minus 3's segments will get us Segment 1
      segment_one = four_segments - three_segments

      # Should be able to figure out segment 5 from 5's segments now...
      # If we take 3's segments, add Segment 1, and remove segments 2+5, whichever number is 5 will contain everything that's left
      fiveish = three_segments + segment_one - one_segments
      five_index = two_or_five_index.find { |possible| (fiveish - digits[possible].split("").to_set).empty? }
      five_segments = digits[five_index].split("").to_set
      segment_five = five_segments - fiveish

      # Which means we also know segment 2
      segment_two = one_segments - segment_five

      # Also, we found two while we were at it, which we can now use to solve segment 4
      two_index = (two_or_five_index - [five_index]).first
      two_segments = digits[two_index].split("").to_set
      segment_four = two_segments - three_segments

      # Now we know everything we care about:
      code = {
        segment_zero.first => 0,
        segment_one.first => 1,
        segment_two.first => 2,
        segment_three.first => 3,
        segment_four.first => 4,
        segment_five.first => 5,
        segment_six.first => 6,
      }

      right_side_number = right_side.split(" ").reduce(0) { |number, segments|
        digit_array = Array.new(7, 0)
        segments.split("").each { |segment| digit_array[code[segment]] = 1}
        digit = patterns[digit_array]
        number * 10 + digit
      }

      sum + right_side_number
    end

pp "Sum: #{total_sum}"