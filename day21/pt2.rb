require 'set'
require 'json'

pos = [0, 3]
scores = [0, 0]

next_player = 0

# [[p1_pos, p2_pos], [p1_score, p2_score], next_player] => [p1_wins, p2_wins]
@states = {}

@rolls = {
  3 => 1,
  4 => 3,
  5 => 6,
  6 => 7,
  7 => 6,
  8 => 3,
  9 => 1,
}

pp "Possible rolls #{@rolls.size} => #{@rolls}"

def turn(pos, scores, next_player, roll)
  player = next_player
  next_player = player == 0 ? 1 : 0
  pos[player] = (pos[player] + roll) % 10
  scores[player] += pos[player] == 0 ? 10 : pos[player]
  state_key = [pos, scores, player]
  found_state = @states[state_key]
  if !found_state.nil?
    # pp "Returning found state: #{state_key} => #{found_state}"
    found_state unless found_state.nil?
  elsif scores[player] >= 21
    wins = [0, 0]
    wins[player] = 1
    @states[state_key] = wins
    # pp "Wins: #{wins} => #{state_key}"
    wins
  else
    # Run next die rolls
    sub_wins = (3..9).reduce([0, 0]) { |wins, roll|
      p1_wins, p2_wins = turn(pos.dup, scores.dup, next_player, roll)
      mult = @rolls[roll]
      wins[0] += p1_wins * mult
      wins[1] += p2_wins * mult
      wins
    }
    # pp "Wins: #{sub_wins} => #{state_key}"
    @states[state_key] = sub_wins
    sub_wins
  end
end

total_wins = (3..9).reduce([0, 0]) { |wins, roll|
  p1_wins, p2_wins = turn(pos.dup, scores.dup, 0, roll)
  mult = @rolls[roll]
  wins[0] += p1_wins * mult
  wins[1] += p2_wins * mult
  wins
}
pp "Total #{total_wins}"