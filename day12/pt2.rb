require "set"

class Node

  def initialize(name)
    @name = name
    @size = name.upcase == name ? :big : :small
    @paths = []
    @visited = 0
  end

  def add(node)
    @paths << node
  end

  def paths
    @paths
  end

  def size
    @size
  end

  def name
    @name
  end

  def small?
    @size == :small
  end

  def big?
    @size == :big
  end

  def can_visit?(small_cave_twice_done)
    return false if name == "start" && @visited == 1
    return big? || @visited == 0 || (!small_cave_twice_done && @visited == 1)
  end


  def visit_paths(small_cave_twice_done)
    return 1 if @name == "end"
    return 0 unless can_visit?(small_cave_twice_done)

    @visited += 1
    small_cave_twice_done ||= small? && @visited > 1
    valid_paths = paths.reduce(0) { |path_count, next_node|
      path_count + next_node.visit_paths(small_cave_twice_done)
    }
    @visited -= 1
    valid_paths
  end
end

@graph = Hash.new { |h, k| h[k] = Node.new(k) }
# Set up initial two nodes
start_node = @graph["start"]
end_node = @graph["end"]

File.readlines('input')
    .each do |line|
      (left, right) = line.strip.split("-")
      left_node = @graph[left]
      right_node = @graph[right]
      left_node.add(right_node)
      right_node.add(left_node)
    end

path_count = start_node.visit_paths(false)

pp "Count? #{path_count}"