require 'set'
require 'json'

pos = [0, 3]
score = [0, 0]

next_player = 0

die_rolls = 0
@next_die = 1

def next_die
  @next_die
end

def next_die=(next_die)
  @next_die = next_die
end

def get_roll
  roll = next_die
  @next_die = 1 + (next_die % 100)
  roll
end

until score[0] >= 1000 || score[1] >= 1000
  player = next_player
  next_player = player == 0 ? 1 : 0
  roll = get_roll + get_roll + get_roll
  pos[player] = (pos[player] + roll) % 10
  score[player] += pos[player] == 0 ? 10 : pos[player]
  pp "Player #{player} advances #{roll} to land on #{pos[player]} and now has score #{score[player]}"
  die_rolls += 3
end

loser = score.min
pp "Result: #{loser} * #{die_rolls} => #{loser * die_rolls}"