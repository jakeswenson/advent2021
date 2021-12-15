import Parsing
import Algorithms
import Collections

func bottomRightNeighbors(_ nums: [[Int]], loc: Coord) -> [Coord] {
    let deltas = [
        (0, 1),
        (1, 0),
    ]

    return deltas.compactMap { (dRow, dCol) in
        let newRow = loc.row + dRow
        if newRow >= 0 && newRow < nums.count {
            let newCol = loc.col + dCol
            if newCol >= 0 && newCol < nums[newRow].count {
                return Coord(newRow, newCol)
            }
        }

        return nil
    }
}

func bottomRightNeighborsWithValues(_ nums: [[Int]], loc: Coord) -> [(value: Int, coord: Coord)] {
    return bottomRightNeighbors(nums, loc: loc).map { idx in
        (value: nums[idx], coord: idx)
    }
}

func printArray(_ nums: [[Int]], path: Set<Coord> = []) {
    nums.enumerated().forEach { row, values in
        print(values.enumerated().map { col, val in
            if path.contains(Coord(row, col)) {
                return "*"
            }

            return "\(val)"
        }.joined())
    }
}

let day15 = problem(day: 15) { input in

    let riskLevels = input.lines.map { line in line.map { c in c.wholeNumberValue! } }

  part1(example: 40, answer: 0) {
      var levels = riskLevels

      let start = Coord(0, 0)

      levels[start] = 0

      let lastRow = levels.index(before: levels.endIndex)
      let lastCol = levels[lastRow].index(before: levels[lastRow].endIndex)
      let end = Coord(lastRow, lastCol)

      let minDistances = stride(from: lastRow, to: -1, by: -1).flatMap { row in
          stride(from: lastCol, to: -1, by: -1).map { col in
            Coord(row, col)
          }
      }.reduce(levels) { distances, loc in
          var distances = distances

          let neighbors = bottomRightNeighborsWithValues(distances, loc: loc)

          let minDistance = neighbors.map { $0.value }.min()
          let distance = (minDistance ?? 0)

          distances[loc] = levels[loc] + distance
          return distances
      }

      var current = start
      var set: Set<Coord> = [start]
      var sum = 0

      while let (value: value, coord: coord) = bottomRightNeighborsWithValues(minDistances, loc: current).min(by: { $0.value < $1.value }) {
          current = coord
          set.insert(current)
          print("sum:", sum, "value:", value)
          sum += levels[coord]
      }

      printArray(riskLevels, path: set)

      return minDistances[start]
  }

    part2(example: nil, answer: nil) {
        return 0
    }
}
