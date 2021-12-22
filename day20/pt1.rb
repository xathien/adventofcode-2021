require 'set'
require 'json'

BASE_SIZE = 100.freeze
# BASE_SIZE = 5.freeze
BUFFER = 10.freeze
SIZE = BASE_SIZE + BUFFER

image = Array.new(SIZE) { Array.new(SIZE, "0") }
File.readlines('input')
    .map(&:strip)
    .each_with_index { |line, row_i|
      row = image[row_i + BUFFER / 2]
      line.split("").each_with_index { |bit, col| row[col + BUFFER / 2] = bit }
    }


algo = File.readlines('input_algo')[0].strip.split("")

def print(image)
  image.each { |row|
    pp row.map { |col| col == "0" ? "." : "#" }.join("")
  }
end

def run(image, algo)
  new_image = image.map(&:dup)
  image[1...image.size - 1].each_with_index { |row, row_i|
    row_i += 1
    new_row = new_image[row_i]
    row[1...image.size - 1].each_with_index { |bit, col_i|
      col_i += 1
      algo_idx = image[row_i-1..row_i+1].reduce("") { |str, adj_row| str + adj_row[col_i-1..col_i+1].join("") }.to_i(2)
      new_bit = algo[algo_idx]
      new_row[col_i] = new_bit
    }
    # Toggle the far left and right columns 'cos that's what they do
    new_row[0] = new_row[1]
    new_row[-1] = new_row[-2]
  }

  # Dup the top and bottom rows
  new_image[0] = new_image[1].dup
  new_image[-1] = new_image[-2].dup

  new_image
end

pp "Image 0"
print(image)

image = run(image, algo)
pp "Image 1"
print(image)

image = run(image, algo)
pp "Image 2"
print(image)

lit_bits = image.reduce(0) { |sum, row|
  sum + row.filter { |col| col == "1" }.size
}
pp "Lit: #{lit_bits}"