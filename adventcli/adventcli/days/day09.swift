import Algorithms
import Collections
import Foundation
import Parsing

struct Coord: Hashable, Equatable {
    let row: Int
    let col: Int

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}

func neighborsIdx(_ nums: [[Int]], loc: Coord) -> [Coord] {
    var neighbors: [Coord] = []
    if loc.row > 0 {
        neighbors.append(Coord(loc.row-1, loc.col))
    }
    if loc.row < nums.endIndex - 1 {
        neighbors.append(Coord(loc.row+1, loc.col))
    }
    if loc.col > 0 {
        neighbors.append(Coord(loc.row, loc.col-1))
    }
    if loc.col < nums[loc.row].endIndex - 1 {
        neighbors.append(Coord(loc.row, loc.col+1))
    }

    return neighbors
}

func neighbors(_ nums: [[Int]], loc: Coord) -> [(value: Int, coord: Coord)] {
    return neighborsIdx(nums, loc: loc).map { idx in
        (value: nums[idx], coord: idx)
    }
}

extension Array where Element == Array<Int> {
    subscript(_ coord: Coord) -> Int { 
        get {
            self[coord.row][coord.col]
        }
        set {
            self[coord.row][coord.col] = newValue
        }
    }

    var points: [Coord] {
        (0..<self.count).flatMap { row -> [Coord] in
            (0..<self[row].count).map { col in Coord(row, col) }
        }
    }
}

let day09 = problem(day: 9) { input in
    let numbers = input.lines.map { $0[...].map { $0.wholeNumberValue! } }

    let lowPoints = numbers.points.filter { loc in
            let value = numbers[loc]
            let neighbors = neighbors(numbers, loc: loc).map(\.value)

            return neighbors.allSatisfy { n in n > value }
        }

    part1(example: 15, answer: 607) {
        let height = numbers.count
        let width = numbers[0].count
        print("\(height)x\(width)")

        let risk = lowPoints.map { numbers[$0] }
            .reduce(0) { risk, value in
                risk + 1 + value
            }

        return risk
    }

    part2(example: 1134, answer: 900864) {
        let largestBasins = lowPoints.map { lowCoord -> Int in 
                var searchQueue: Deque = [lowCoord]
                var basinSize = 0

                var visited: [Coord: Bool] = [:]

                while let loc = searchQueue.popFirst() {
                    if visited[loc, default: false] {
                        continue
                    }
                    visited[loc] = true
                    
                    basinSize += 1

                    let val = numbers[loc]
                    let nearBy: [Coord] = neighbors(numbers, loc: loc).filter { neighbor in
                        return neighbor.value > val && neighbor.value != 9 && !visited[neighbor.coord, default: false]
                    }.map(\.coord)

                    if !nearBy.isEmpty {
                        searchQueue.append(contentsOf: nearBy)
                    }
                }

                return basinSize
            }.max(count: 3)

        return largestBasins.reduce(1, *)
    }
}
