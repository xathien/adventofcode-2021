require "set"

open_tokens = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">",
}

scores = {
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137,
}


total_score = File.readlines('input')
    .reduce(0) do |score_acc, line|
      stack = []
      score_acc +
        line.strip.split("").reduce(0) { |_, token|
          if open_tokens.include?(token)
            stack << token
          else
            open_token = stack.pop
            break scores[token] if open_tokens[open_token] != token
          end
          0
        }
    end

pp "Score: #{total_score}"