require 'set'

x_range, y_range = target_area = [144..178, -100..-76]

success = 0
(16..178).each { |vx0|
  (-100..5000).each { |vy0|
    y = 0
    x = 0
    vx = vx0
    vy = vy0
    success += loop {
      x += vx
      vx -=1 if vx > 0
      y += vy
      vy -= 1
      break 0 if y < -100 || x > 178
      break 1 if x_range.include?(x) && y_range.include?(y)
    }

  }
}

pp "Success: #{success}"
