require 'set'
require 'json'

class Beacon
  attr_accessor :x, :y, :z, :distances, :scanner

  def initialize(scanner, x, y, z)
    @scanner = scanner
    @x = x
    @y = y
    @z = z
    @distances = {}
  end

  def coords
    return x, y, z
  end

  def add_distance(distance, *coords)
    @distances[distance] = coords
  end
end

class Scanner
  attr_accessor :id, :beacons, :orientation, :scanner_coords

  def initialize(id)
    @id = id
    @beacons = {}
    @orientation = id == 0 ? [1, 1, 1] : nil
    @scanner_coords = [[0, 0, 0]]
  end

  def mark_distances
    all_bs = beacons.values
    all_bs.each_with_index { |beacon1, index|
      all_bs.drop(index + 1).each { |beacon2|
        mark_distance(beacon1, beacon2)
      }
    }
  end

  def mark_distance(beacon1, beacon2)
    x1, y1, z1 = beacon1.coords
    x2, y2, z2 = beacon2.coords
    distance = [(x1 - x2).abs, (y1 - y2).abs, (z1 - z2).abs].to_set
    beacon1.add_distance(distance, x2, y2, z2)
    beacon2.add_distance(distance, x1, y1, z1)
  end

  def compare(other)
    mapping, coord_diff = check_absorb(other)

    return if mapping.nil?
    # Now we can absorb all of their beacons, muahahah
    absorbed = 0
    other.beacons.keys.each { |other_coords|
      translated_coords = translate(other_coords, mapping, coord_diff)
      unless beacons.key?(translated_coords)
        absorbed += 1
        beacon_to_absorb = Beacon.new(self, *translated_coords)
        absorb_beacon(beacon_to_absorb)
      end
    }

    @scanner_coords << coord_diff
  end

  def check_absorb(other)
    other_bs = other.beacons
    beacons.each { |coords, beacon|
      distances = beacon.distances
      shared_distances = nil
      found_match = other_bs.each { |other_coords, other_b|
        other_d = other_b.distances
        shared_distances = distances.keys.filter { |k| other_d.key?(k) }
        if shared_distances.size > 3
          x1, y1, z1 = coords
          unordered_distance = shared_distances.first
          x2, y2, z2 = distances[unordered_distance]
          ordered_distance = [(x1 - x2), (y1 - y2), (z1 - z2)]
          x3, y3, z3 = other_coords
          x4, y4, z4 = other_d[unordered_distance]
          other_ordered_distance = [x3 - x4, y3 - y4, z3 - z4]

          mapping = other_ordered_distance.map { |n|
            case n
              # Unroll loop for efficiency, not just because I'm feeling weird
            when ordered_distance[0]
              [1, 0]
            when ordered_distance[1]
              [1, 1]
            when ordered_distance[2]
              [1, 2]
            when -1 * ordered_distance[0]
              [-1, 0]
            when -1 * ordered_distance[1]
              [-1, 1]
            when -1 * ordered_distance[2]
              [-1, 2]
            end
          }

          # Reoriented coordinates
          ordered_coords = reorder_coords(other_coords, mapping)

          # Translated coordinates -- where the eff is the other scanner
          coord_diff = beacon.coords.zip(ordered_coords).map { |c1, c2|
            c1 - c2
          }
          return mapping, coord_diff
        end
      }
    }
    nil
  end

  def reorder_coords(coords, mapping)
    ordered_coords = []
    coords.each_with_index { |n, index|
      multiplier, new_index = mapping[index]
      ordered_coords[new_index] = multiplier * n
    }
    ordered_coords
  end

  def translate(coords, mapping, coord_diff)
    ordered_coords = reorder_coords(coords, mapping)
    ordered_coords.zip(coord_diff).map { |c1, c2| c1 + c2 }
  end

  def absorb_beacon(new_beacon)
    beacons.values.each { |beacon|
      mark_distance(beacon, new_beacon)
    }
    beacons[new_beacon.coords] = new_beacon
  end
end

scanners = []
scanner = nil
File.readlines('input')
    .map(&:strip)
    .each { |line|
      if line.empty?
        scanner.mark_distances
        next
      elsif line[0..2] == "---"
        # Start up a new scanner
        id = line.split(" ")[2]
        scanner = Scanner.new(id)
        scanners << scanner
        next
      end

      coords = line.split(",").map(&:to_i)
      scanner.beacons[coords] = Beacon.new(scanner, *coords)
    }
scanner.mark_distances

scanner = scanners.slice!(0)
while scanners.size > 1
  size_before = scanners.size
  scanners.each_with_index { |scanner2, index|
    next if scanner2.nil?
    matched = scanner.compare(scanner2)
    scanners[index] = nil if matched
  }
  scanners = scanners.compact
end

largest_distance = 0
scanner.scanner_coords.each_with_index { |coords, index|
  scanner.scanner_coords.drop(index + 1).each { |coords2|
    x1, y1, z1 = coords
    x2, y2, z2 = coords2
    distance = (x1 - x2).abs + (y1 - y2).abs + (z1 - z2).abs
    largest_distance = distance if distance > largest_distance
  }
}

pp "Largest: #{largest_distance}"