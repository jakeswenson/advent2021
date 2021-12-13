import Algorithms
import Collections
import Foundation
import Parsing

struct Day13Pair: Hashable, Equatable, CustomDebugStringConvertible {
  var debugDescription: String {
    "(\(x), \(y))"
  }

  let x: Int, y: Int
}

let points =
  Int.parser()
  .skip(",".utf8)
  .take(Int.parser())
  .map { Day13Pair(x: $0, y: $1) }

let manyPoints = Many(points, separator: Whitespace())

enum FoldingAlong {
  case x(Int)
  case y(Int)
}

let foldAlong = Skip(StartsWith("fold along".utf8)).skip(Whitespace())
  .take(OneOfMany("x".utf8.map { FoldingAlong.x }, "y".utf8.map { FoldingAlong.y }))
  .skip("=".utf8)
  .take(Int.parser())
  .map { $0($1) }

let folds = Many(foldAlong, separator: Whitespace())

let problem = manyPoints.skip(Whitespace()).take(folds)

func displayMap(_ result: Set<Day13Pair>) {
  let maxX = result.map { $0.x }.max()!
  let maxY = result.map { $0.y }.max()!

  let map = (0...maxY).map { y in
    (0...maxX).map { x -> String in
      result.contains(Day13Pair(x: x, y: y)) ? "#" : "."
    }.joined()
  }.joined(separator: "\n")

  print(map)
}

func foldPoints(points: Set<Day13Pair>, along: FoldingAlong) -> Set<Day13Pair> {
  switch along {
  case .y(let y):
    return Set(
      points.map { (point: Day13Pair) in
        point.y <= y ? point : Day13Pair(x: point.x, y: (2 * y) - point.y)
      })
  case .x(let x):
    return Set(
      points.map { (point: Day13Pair) in
        point.x <= x ? point : Day13Pair(x: (2 * x) - point.x, y: point.y)
      })
  }
}

let day13 = problem(day: 13) { input in
  let (points, folds) = problem.parse(input.utf8)!

  part1(example: 17, answer: 618) {

    let result = folds[..<1].reduce(Set(points)) { foldPoints(points: $0, along: $1) }

    return result.count
  }

  part2(example: 8, answer: 8) {

    let result = folds.reduce(Set(points)) { foldPoints(points: $0, along: $1) }

    print("The Code is:")
    displayMap(result)

    return "ALREKFKU".count
  }
}
