require 'set'
require 'json'

input_array =
         [ 9,  9,  4,  2,  9,   7,  9,  5,   9,  9,   3,  9,  2,   9] # pt 1
input_array =
         [ 1,  8,  1,  1,  3,   1,  8,  1,   5,  7,   1,  6,  1,   1] # pt 2
x_adds = [10, 10, 14, 11, 14, -14,  0, 10, -10, 13, -12, -3, -11, -2]
z_pops = [ 0,  0,  0,  0,  0,   1,  1,  0,   1,  0,   1,  1,   1,  1]
y_adds = [ 2,  4,  8,  7, 12,   7, 10, 14,   2,  6,   8, 11,   5, 11]

z_pops = [false, false, false, false, false, true, true, false, true, false, true, true, true, true]

check = 0
z_vals = [0]

input_array.each_with_index { |number, i|
  check = z_vals.last % 26 + x_adds[i] # check in (-14..39) ?
  pp "#{number} MUST EQUAL #{check}!" if z_pops[i]
  z_vals.pop if z_pops[i]
  z_vals << number + y_adds[i] if check != number
  pp "Memory 2: #{[number, check, z_vals]}"
}