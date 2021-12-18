require 'set'
require 'json'

class Node
  attr_accessor :left, :right, :left_index, :right_index, :type, :parent, :value

  def initialize(problem, parent, start_index)
    @parent = parent
    if problem.is_a?(Array)
      left, right = problem
      @left = Node.new(left, self, start_index)
      @left_index = @left.right_index
      @right = Node.new(right, self, @left_index + 1)
      @right_index = @right.right_index
      @type = :pair
    elsif problem.is_a?(Node)
      # parent is the left tree here
      @left = parent
      @left.update_indexes(0)
      @left_index = @left.right_index
      @left.parent = self
      @right = problem
      @right.update_indexes(@left_index + 1)
      @right_index = @right.right_index
      @right.parent = self
      @type = :pair
      @parent = nil
    else
      @value = problem
      @right_index = start_index
      @type = :value
    end
  end

  def iterate(method)
    left.iterate(method) if !left.nil?
    method.call(self)
    right.iterate(method) if !right.nil?
  end

  def update_indexes(start_index = 0)
    case type
    when :value
      @right_index = start_index
    when :pair
      @left_index = left.update_indexes(start_index)
      @right_index = right.update_indexes(left_index + 1)
    end
    right_index
  end

  def reduce
    something_reduced = true
    while something_reduced
      something_reduced = find_explosion
      something_reduced = find_split if !something_reduced
      update_indexes if something_reduced
    end
    self
  end

  def find_explosion(depth = 0)
    return false if type == :value
    if depth == 4 && left.type == :value && right.type == :value
      explode
      return true
    end
    return true if left.find_explosion(depth + 1) || right.find_explosion(depth + 1)
    false
  end

  def explode
    left_i = left.right_index
    if left_i > 0
      prev_value = find(left_i - 1)
      prev_value.value += left.value
    end
    right_i = right.right_index
    next_value = find(right_i + 1)
    next_value.value += right.value if !next_value.nil?

    @type = :value
    @value = 0
    @left = nil
    @right = nil
    # index will be fixed later
  end

  def find_split
    if type == :value
      if @value < 10
        return false
      end

      left_value = @value / 2
      right_value = left_value + (@value % 2)
      @value = nil
      @type = :pair
      # Indexes fixed later
      @left = Node.new(left_value, self, 0)
      @right = Node.new(right_value, self, 0)
      return true
    end

    left.find_split || right.find_split
  end

  def find(index)
    current = self
    # Head to the root to start the search
    current = current.parent until current.parent.nil?
    until current.nil?
      return current if current.type == :value && current.right_index == index

      if !current.left_index.nil? && index <= current.left_index
        current = current.left
      else
        current = current.right
      end
    end

    # Doesn't exist
    return nil
  end

  def magnitude
    return @value if type == :value
    3 * left.magnitude + 2 * right.magnitude
  end

  def inspect
    if type == :pair
      "[#{left.inspect},#{right.inspect}]"
    else
      value
    end
  end
end

problems = File.readlines('input')
    .map do |line| JSON.parse(line.strip) end

largest_magnitude = 0
problems.each_with_index { |first_problem_json, index|
  problems.each_with_index { |second_problem_json, index2|
    next if index == index2

    first_problem = Node.new(first_problem_json, nil, 0).reduce
    second_problem = Node.new(second_problem_json, nil, 0).reduce
    combined = Node.new(second_problem, first_problem, 0).reduce.magnitude
    largest_magnitude = combined if combined > largest_magnitude
  }
}
pp "L: #{largest_magnitude}"