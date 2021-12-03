class Node
  def initialize(digit)
    @digit = digit
    @zero = nil
    @one = nil
    @zeros = 0
    @ones = 0
  end

  def add(str)
    return if str.nil? || str.empty?

    char = str[0]
    rest = str[1..-1]
    if char == '0'
      @zero = Node.new('0') if @zero.nil?
      @zero.add(rest)
      @zeros += 1
    else
      @one = Node.new('1') if @one.nil?
      @one.add(rest)
      @ones += 1
    end
  end

  def most_common
    @digit +
      if @ones + @zeros == 0
        ''
      elsif @ones >= @zeros
        @one.most_common
      else
        @zero.most_common
      end
  end

  def least_common
    @digit +
      if @ones + @zeros == 0
        ''
      elsif @zeros <= @ones && @zeros > 0 || @ones == 0
        @zero.least_common
      else
        @one.least_common
      end
  end
end

root = Node.new('')

File.readlines('input')
    .map do |line|
      root.add line.strip
    end

o2 = root.most_common
co2 = root.least_common
o2_num = o2.to_i(2)
co2_num = co2.to_i(2)
pp "O2: #{o2} - CO2: #{co2}"
pp "O2: #{o2_num} - CO2: #{co2_num}"

pp o2_num * co2_num
