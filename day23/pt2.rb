require 'set'
require 'json'

ROOM_COORDS = [2, 4, 6, 8].freeze

start_rooms = [
  [10, 1000, 1000, 100],
  [100, 100, 10, 1000],
  [1, 10, 1, 1000],
  [10, 1, 100, 1]
]
start_hallway = Array.new(11, 0)

@known_states = {}
@goal_rooms = {
  1 => 0,
  10 => 1,
  100 => 2,
  1000 => 3,
}

@lowest_cost = Float::INFINITY

def run(rooms, hallway, cost_so_far)
  return false if cost_so_far > @lowest_cost

  finished = rooms.all? { |room| room.uniq.size == 1 && room[0] > 0 }
  if finished
    @lowest_cost = cost_so_far if cost_so_far < @lowest_cost
    return true
  end

  state_key = [rooms, hallway]
  return false if @known_states.fetch(state_key, Float::INFINITY) <= cost_so_far

  @known_states[state_key] = cost_so_far

  hallway.each_with_index do |weight, hallway_coord|
    next if weight == 0

    goal_room = @goal_rooms[weight]
    target_hallway_coord = ROOM_COORDS[goal_room]

    step = target_hallway_coord > hallway_coord ? -1 : 1
    # Hallway's clogged between us and our goal
    next if (target_hallway_coord...hallway_coord).step(step).any? { |next_coord| hallway[next_coord] > 0 }

    other_room = rooms[goal_room]
    # The room is unclean
    next if other_room.any? { |other_weight| other_weight > 0 && other_weight != weight }

    target_depth = other_room.each_with_index { |other_weight, depth|
      next if other_weight == 0
      break depth - 1
    }
    next if target_depth.nil?

    target_depth = 3 if target_depth.is_a?(Array) # Room is empty, head to the bottom!

    cost = ((hallway_coord - target_hallway_coord).abs + target_depth + 1) * weight
    new_rooms = rooms.map(&:dup)
    new_hallway = hallway.dup
    new_hallway[hallway_coord] = 0
    new_rooms[goal_room][target_depth] = weight
    run(new_rooms, new_hallway, cost + cost_so_far)
  end

  rooms.each_with_index { |room, index|
    # Empty, or everyone's happy to be here
    next if room.all? { |weight| weight == 0 || index == @goal_rooms[weight] }

    weight, depth = room.each_with_index { |weight, depth|
      break weight, depth if weight > 0
    }

    hallway_coord = ROOM_COORDS[index]

    # Move left down the hall
    (hallway_coord - 1..0).step(-1).each do |target_hallway_coord|
      break if hallway[target_hallway_coord] > 0 # Hallway's clogged

      if target_hallway_coord == 2 || target_hallway_coord == 4 || target_hallway_coord == 6 || target_hallway_coord == 8
        next # Can't stop in front of a door
      end

      cost = (depth + 1 + (hallway_coord - target_hallway_coord).abs) * weight
      new_rooms = rooms.map(&:dup)
      new_hallway = hallway.dup
      new_hallway[target_hallway_coord] = weight
      new_rooms[index][depth] = 0
      run(new_rooms, new_hallway, cost + cost_so_far)
    end

    # Move right down the hall
    (hallway_coord + 1..10).each do |target_hallway_coord|
      break if hallway[target_hallway_coord] > 0 # Hallway's clogged

      if target_hallway_coord == 2 || target_hallway_coord == 4 || target_hallway_coord == 6 || target_hallway_coord == 8
        next # Can't stop in front of a door
      end

      cost = (depth + 1 + (hallway_coord - target_hallway_coord).abs) * weight
      new_rooms = rooms.map(&:dup)
      new_hallway = hallway.dup
      new_hallway[target_hallway_coord] = weight
      new_rooms[index][depth] = 0
      run(new_rooms, new_hallway, cost + cost_so_far)
    end
  }
end

run(start_rooms, start_hallway, 0)

pp "Lowest: #{@lowest_cost}"
