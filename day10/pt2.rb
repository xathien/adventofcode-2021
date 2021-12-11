require "set"

open_tokens = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">",
}

scores = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}


total_scores = File.readlines('input')
    .map { |line|
      stack = []
      result =
        line.strip.split("").each { |token|
          if open_tokens.include?(token)
            stack << token
          else
            open_token = stack.pop
            break :invalid if open_tokens[open_token] != token
          end
        }
      next if result == :invalid || stack.empty?

      total_score = stack.reverse.reduce(0) { |score, open_token|
        5 * score + scores[open_tokens[open_token]]
      }
      pp "Total score: #{total_score} => #{stack}"
      total_score
    }
    .compact
    .sort

pp "Median Score: #{total_scores[total_scores.size / 2]}"