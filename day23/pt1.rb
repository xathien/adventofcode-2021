require 'set'
require 'json'

ROOM_COORDS = [2, 4, 6, 8].freeze

start_rooms = [
  [10, 100],
  [100, 1000],
  [1, 1000],
  [10, 1]
]
# start_rooms = [
#   [10, 1],
#   [100, 1000],
#   [10, 100],
#   [1000, 1]
# ]
# start_rooms = [
#   [10, 1],
#   [0, 1000],
#   [100, 100],
#   [1000, 1]
# ]
start_hallway = Array.new(11, 0)
# start_hallway[3] = 10

@known_states = Set.new

@goal_rooms = {
  1 => 0,
  10 => 1,
  100 => 2,
  1000 => 3,
}

def distances_from_home(rooms, hallway)
  total_energy_distances = 0
  rooms.each_with_index do |(upper, lower), index|
    next if lower == 0 || lower == upper

    if upper > 0
      goal_room = @goal_rooms[upper]
      total_energy_distances += find_cost(upper, :room, [index, 0], :room, [goal_room, 1])
    end

    goal_room = @goal_rooms[lower]
    if index != goal_room
      target_location = rooms[goal_room][1] == lower ? 0 : 1
      total_energy_distances += find_cost(lower, :room, [index, 1], :room, [goal_room, target_location])
    end
  end

  hallway.each_with_index do |weight, index|
    next if weight == 0
    goal_room = @goal_rooms[weight]
    total_energy_distances += find_cost(weight, :hallway, index, :room, [goal_room, 1])
  end

  total_energy_distances
end

def find_cost(weight, start_type, start_coord, end_type, end_coord)
  distance = 0
  hallway_coord = start_coord
  if start_type == :room
    room_num, location = start_coord
    distance += location + 1
    hallway_coord = ROOM_COORDS[room_num]
  end

  if end_type == :room
    room_num, location = end_coord
    end_hallway_coord = ROOM_COORDS[room_num]
    distance += (end_hallway_coord - hallway_coord).abs + location + 1
  else
    distance += (end_coord - hallway_coord).abs
  end

  cost = weight * distance
  # pp "Costs #{cost} for #{weight} from #{start_type} #{start_coord} => #{end_type} #{end_coord}"
  cost
end

@lowest_distances = Float::INFINITY

def move(move_queue, rooms, hallway, cost_so_far, path, start_type, start_coord, end_type, end_coord)
  rooms = rooms.map(&:dup)
  hallway = hallway.dup
  path = path.dup

  weight = nil
  if start_type == :room
    room, location = start_coord
    weight = rooms[room][location]
    rooms[room][location] = 0
  else
    weight = hallway[start_coord]
    hallway[start_coord] = 0
  end

  cost = cost_so_far + find_cost(weight, start_type, start_coord, end_type, end_coord)
  path << [rooms, hallway, cost]

  if end_type == :room
    room, location = end_coord
    rooms[room][location] = weight
  else
    hallway[end_coord] = weight
  end

  new_distances = distances_from_home(rooms, hallway)
  if new_distances < @lowest_distances
    pp "Found new lowest distance: #{new_distances}"
    print_board(rooms, hallway)
    @lowest_distances = new_distances
  end
  heuristic = -(cost + new_distances)
  # pp "Moving: #{weight} from #{start_type} #{start_coord} => #{end_type} #{end_coord} costs #{find_cost(weight, start_type, start_coord, end_type, end_coord)} and has heuristic #{heuristic}"
  # heuristic = cost + hallway.sum # Is this even a good heuristic..?
  insert_index = move_queue.bsearch_index { |_, _, _, _, h| h >= heuristic } || move_queue.size
  state = [rooms, hallway, cost, path, heuristic]
  set_state = [rooms, hallway]
  # if @known_states.include?(set_state)
  #   pp "I've tried this state already: #{set_state} | Came from path #{path[-2..]}"
  # else
  #   @known_states << set_state
  # end
  move_queue.insert(insert_index, state)
end

def find_legal_moves(move_queue, rooms, hallway, cost_so_far, path)
  before = move_queue.size
  rooms.each_with_index do |(upper, lower), index|
    next if upper == lower # Crab won't leave home (or there's no crabs here)

    weight = nil
    room_pos = nil
    if upper > 0 # Top crab can move
      weight = upper
      room_pos = 0
    else # Lower can move somewhere if it wants, technically
      weight = lower
      room_pos = 1
    end

    hallway_coord = ROOM_COORDS[index]
    goal_room = @goal_rooms[weight]
    goal_room_coord = ROOM_COORDS[goal_room]

    next if index == goal_room && room_pos == 1 # We're already home
    # pp "Crab #{weight} in room #{index}/#{hallway_coord} can move from pos #{room_pos} and wants to go to room #{goal_room} at #{goal_room_coord}"

    start_coord = [index, room_pos]
    # Move left down the hall
    (hallway_coord - 1..0).step(-1).each do |target_hallway_coord|
      break if hallway[target_hallway_coord] > 0 # Hallway's clogged

      # See if we can/should move into a room from here
      if target_hallway_coord == goal_room_coord
        other_upper, other_lower = rooms[goal_room]
        if other_upper == 0 && weight == other_lower
          # Go home! No more moves needed, either
          move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :room, [goal_room, 0])
          break
        elsif other_lower == 0
          move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :room, [goal_room, 1])
          break
        end
        next # Not our room; carry on
      elsif target_hallway_coord == 2 || target_hallway_coord == 4 || target_hallway_coord == 6 || target_hallway_coord == 8
        next # Can't stop in front of a door
      end

      move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :hallway, target_hallway_coord)
    end

    # Move right down the hall -- I should probably be ashamed for copy/pasting this but eh
    (hallway_coord + 1..10).each do |target_hallway_coord|
      break if hallway[target_hallway_coord] > 0 # Hallway's clogged

      # See if we can/should move into a room from here
      if target_hallway_coord == goal_room_coord
        other_upper, other_lower = rooms[goal_room]
        if other_upper == 0 && weight == other_lower
          # Go home! No more moves needed, either
          move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :room, [goal_room, 0])
          break
        elsif other_lower == 0
          move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :room, [goal_room, 1])
          break
        end
        next # Not our room; carry on
      elsif target_hallway_coord == 2 || target_hallway_coord == 4 || target_hallway_coord == 6 || target_hallway_coord == 8
        next # Can't stop in front of a door
      end

      # Try moving out if we have somewhere to go
      move(move_queue, rooms, hallway, cost_so_far, path, :room, start_coord, :hallway, target_hallway_coord)
    end
  end

  hallway.each_with_index do |weight, index|
    next if weight == 0

    goal_room = @goal_rooms[weight]
    goal_room_coord = ROOM_COORDS[goal_room]

    step = goal_room_coord > index ? -1 : 1
    # Hallway's clogged between us and our goal
    next if (goal_room_coord...index).step(step).any? { |next_coord| hallway[next_coord] > 0 }

    upper, lower = rooms[goal_room]
    if upper == 0 # There's space in the room...
      if lower == weight # ... at the top!
        move(move_queue, rooms, hallway, cost_so_far, path, :hallway, index, :room, [goal_room, 0])
      elsif lower == 0 # ... at the bottom!
        move(move_queue, rooms, hallway, cost_so_far, path, :hallway, index, :room, [goal_room, 1])
      end
    end
  end

  after = move_queue.size
  if after > before
    # pp "Added #{after - before} new moves"
  else
    # pp "No more legal moves for this board!"
    # print_board(rooms, hallway)
  end
end

def weight_to_letter
  @weight_to_letter ||= {
    0 => '.',
    1 => 'A',
    10 => 'B',
    100 => 'C',
    1000 => 'D'
  }
end

def print_board(rooms, hallway)
  puts '#############'
  puts '#' + hallway.map { |weight| weight_to_letter[weight] }.join('') + '#'
  puts '###' + rooms.map { |upper, _| weight_to_letter[upper] }.join('#') + '###'
  puts '  #' + rooms.map { |_, lower| weight_to_letter[lower] }.join('#') + '#  '
  puts '  #########'
end

lowest_cost = Float::INFINITY
move_queue = []
path = []
find_legal_moves(move_queue, start_rooms, start_hallway, 0, path)


print_board(start_rooms, start_hallway)

until move_queue.empty?
  rooms, hallway, cost_so_far, path, heuristic = move_queue.pop
  next if cost_so_far > lowest_cost
  # pp "Next board to check with cost #{heuristic} => #{rooms} | #{hallway} | #{cost_so_far}"
  finished = rooms.all? { |upper, lower| upper > 0 && upper == lower }
  if finished
    if cost_so_far < lowest_cost
      pp "NEW BEST PATH FOUND #{cost_so_far}"
      lowest_cost = cost_so_far
      path.each_with_index { |(rooms, hallway, cost), index| pp "Cost at step #{index + 1} => #{cost}"; print_board(rooms, hallway) }
    end
    next
  end

  find_legal_moves(move_queue, rooms, hallway, cost_so_far, path)
end

pp "Lowest: #{lowest_cost}"

#############
#...........#
###B#C#A#B###
  #C#D#D#A#
  #########

  5
#############
#.A.........#
###B#C#.#B###
  #C#D#D#A#
  #########

  65
#############
#.A.B.......#
###B#C#.#.###
  #C#D#D#A#
  #########

  68
#############
#.A.B.....A.#
###B#C#.#.###
  #C#D#D#.#
  #########

  14349
#############
#.A.......A.#
###A#B#C#D###
  #A#B#C#D#
  #########