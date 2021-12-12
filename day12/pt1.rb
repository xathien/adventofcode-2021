require "set"

class Node

  def initialize(name)
    @name = name
    @size = name.upcase == name ? :big : :small
    @paths = []
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

  def visit_paths(visited)
    return 1 if @name == "end"
    return 0 if visited.include?(self)

    visited << self if small?
    valid_paths = paths.reduce(0) { |path_count, next_node|
      path_count + next_node.visit_paths(visited)
    }
    visited.delete(self) if small?
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

path_count = start_node.visit_paths(Set.new)

pp "Count? #{path_count}"