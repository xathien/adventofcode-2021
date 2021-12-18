require 'set'

x_range, y_range = target_area = [144..178, -100..-76]
max_y = 0
vx0 = 17

(1..5000).each { |vy0|
  y = 0
  x = 0
  vx = vx0
  vy = vy0
  sub_max_y = 0
  thresholded = loop {
    x += vx
    vx -=1 if vx > 0
    y += vy
    vy -= 1
    sub_max_y = y if vy == 0
    break false if y < -100 || x > 178
    break true if x_range.include?(x) && y_range.include?(y)
  }
  max_y = sub_max_y if thresholded === true && sub_max_y > max_y
}

pp "Max: #{max_y}"
