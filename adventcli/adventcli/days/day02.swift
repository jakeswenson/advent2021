import Algorithms
import Foundation
// https://developer.apple.com/forums/thread/123614?answerId=652452022#652452022
import Parsing
import SwiftUI

enum Movement {
  case forward(_ distance: Int)
  case up(_ depth: Int)
  case down(_ depth: Int)
}

extension Input {
  func parseMovements() -> [Movement]? {
    let direction = StartsWith("forward").map { Movement.forward }
      .orElse(StartsWith("up").map { Movement.up })
      .orElse(StartsWith("down").map { Movement.down })
      .skip(" ")
      .take(Int.parser())
      .map { $0($1) }

    let directions = Many(direction, separator: "\n")

    return directions.parse(self.text)
  }
}

struct Part1State {
  let depth: Int
  let distance: Int

  init() {
    depth = 0
    distance = 0
  }

  private init(depth: Int, distance: Int) {
    self.depth = depth
    self.distance = distance
  }

  func dive(_ depth: Int) -> Self {
    Part1State(depth: self.depth + depth, distance: distance)
  }

  func forward(_ distance: Int) -> Self {
    Part1State(depth: depth, distance: self.distance + distance)
  }
}

let day02 = problem(day: 2) { input in
  let movements = input.parseMovements()!

  part1(example: 150, answer: 1_694_130) {
    let result = movements.reduce(Part1State()) { state, route in
      switch route {
      case let .forward(distance): return state.forward(distance)
      case let .up(depth): return state.dive(-depth)
      case let .down(depth): return state.dive(depth)
      }
    }

    return result.depth * result.distance
  }

  part2(example: 900, answer: 1_698_850_445) {
    let result2 = movements.reduce((depth: 0, distance: 0, aim: 0)) { state, route in
      var state = state

      switch route {
      case let .forward(distance):
        state.distance += distance
        state.depth += distance * state.aim
      case let .up(depth):
        state.aim -= depth
      case let .down(depth):
        state.aim += depth
      }

      return state
    }

    return result2.depth * result2.distance
  }
}
