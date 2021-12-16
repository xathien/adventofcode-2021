require 'set'

class Node
  def initialize(version, type)
    @version = version
    @type = type
    @value = nil
    @end_offset = 0
    @children = []
  end

  def add_child(node)
    children << node
  end

  def children
    @children
  end

  def version
    @version
  end

  def value=(value)
    @value = value
  end

  def value
    @value
  end

  def end_offset=(end_offset)
    @end_offset = end_offset
  end

  def end_offset
    @end_offset
  end
end

line = File.readlines('input')[0]
@input_b = line.strip.to_i(16).to_s(2)

def input_b
  @input_b
end

def packet_types
  @packet_types ||= {
    0 => :operator,
    1 => :operator,
    2 => :operator,
    3 => :operator,
    4 => :number,
    5 => :operator,
    6 => :operator,
    7 => :operator,
  }
end

def operators
  @operators ||= {
    0 => :+,
    1 => :*,
    2 => :min,
    3 => :max,
    5 => :>,
    6 => :<,
    7 => :==
  }
end

def parse_packet(offset)
  version = input_b[offset..offset+2].to_i(2)
  type_id = input_b[offset+3..offset+5].to_i(2)
  type = packet_types[type_id]

  offset += 6

  node = Node.new(version, type)

  case type
  when :operator
    length_type_id = input_b[offset]
    offset += 1
    case length_type_id
    when "0" # 15-bits of packet-bit-length
      bit_length = input_b[offset..offset+14].to_i(2)
      offset += 15
      target_end_offset = offset + bit_length
      until offset >= target_end_offset
        child, offset = parse_packet(offset)
        node.add_child(child)
      end
    when "1" # number of sub-packets
      packet_count = input_b[offset..offset+10].to_i(2)
      offset += 11
      (1..packet_count).each { |_|
        child, offset = parse_packet(offset)
        node.add_child(child)
      }
    end

    operator = operators[type_id]
    pp "Operator #{operator} on #{node.inspect}"
    case operator
    when :+
      node.value = node.children.sum { |child| child.value }
    when :*
      node.value = node.children.reduce(1) { |product, child| product * child.value }
    when :min
      node.value = node.children.min_by { |child| child.value }.value
    when :max
      node.value = node.children.max_by { |child| child.value }.value
    when :>
      node.value = node.children[0].value > node.children[1].value ? 1 : 0
    when :<
      node.value = node.children[0].value < node.children[1].value ? 1 : 0
    when :==
      node.value = node.children[0].value == node.children[1].value ? 1 : 0
    end
  when :number
    last_leading_bit = "1"
    number_str = ""
    until last_leading_bit == "0"
      last_leading_bit = input_b[offset]
      number_str << input_b[offset+1..offset+4]
      offset += 5
    end
    node.value = number_str.to_i(2)
  end

  [node, offset]
end

root, = parse_packet(0)

pp "Result: #{root.value}"
