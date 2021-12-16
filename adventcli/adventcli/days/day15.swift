import Algorithms
import AppKit
import Collections
import Parsing

func printArray(_ nums: [[Int]], path: Set<Coord> = []) {
  nums.enumerated().forEach { row, values in
    print(
      values.enumerated().map { col, val in
        if path.contains(Coord(row, col)) {
          return "*"
        }

        return "\(val)"
      }.joined())
  }
}

func findPath(_ riskLevels: [[Int]]) -> Int {
  let start = Coord(0, 0)
  let end = Coord(riskLevels.endIndex - 1, riskLevels.endIndex - 1)

  var visited: Set<Coord> = []
  var minHeap: Heap<PriorityPair<Coord>> = Heap.minHeap().insert(
    PriorityPair(priority: 0, item: start))

  while let (item, newHeap) = minHeap.removeFirst() {
    let loc = item.item
    minHeap = newHeap

    if loc == end {
      return item.priority
    }

    if visited.contains(loc) {
      continue
    }

    visited.insert(item.item)

    minHeap = neighbors(riskLevels, loc: loc)
      .filter { !visited.contains($0.coord) }
      .reduce(newHeap) { newHeap, n in
        newHeap.insert(PriorityPair(priority: item.priority + n.value, item: n.coord))
      }
  }

  return -1
}

let day15 = problem(day: 15) { input in

  let riskLevels = input.lines.map { line in line.map { c in c.wholeNumberValue! } }

  part1(example: 40, answer: 739) {
    return findPath(riskLevels)
  }

  part2(example: 315, answer: 3040) {
    func addWrap10(_ n: Int, add: Int) -> Int {
      let v = n + add
      if v > 9 {
        return v - 9
      }
      return v
    }

    let expandColumns: [[Int]] = riskLevels.map { row in
      let newRow = (0..<5).flatMap { copyLevel in
        row.map { addWrap10($0, add: copyLevel) }
      }

      return newRow
    }

    let biggerMap = (0..<5).flatMap { rowLevel in
      expandColumns.map { row in
        row.map { addWrap10($0, add: rowLevel) }
      }
    }

    return findPath(biggerMap)
  }
}
