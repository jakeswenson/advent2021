import Algorithms
import Foundation
// https://developer.apple.com/forums/thread/123614?answerId=652452022#652452022
import Parsing

func day02() {
    let file = "/code/advent2021/problems/problem02.txt"

    let path = URL(fileURLWithPath: file)
    let text = try! String(contentsOf: path)

    enum Route {
        case forward(num: Int)
        case up(num: Int)
        case down(num: Int)
    }

    let direction = StartsWith("forward").map { Route.forward(num:) }
        .orElse(StartsWith("up").map { Route.up(num:) })
        .orElse(StartsWith("down").map { Route.down(num:) })
        .skip(" ")
        .take(Int.parser())
        .map { $0($1) }

    let directions = Many(direction, separator: "\n")

    let results = directions.parse(text) ?? []

    let result = results.reduce((depth: 0, distance: 0)) {
        state, route in
        var state = state
        switch route {
        case let .forward(num):
            state.distance += num
        case let .up(num):
            state.depth -= num
        case let .down(num):
            state.depth += num
        }

        return state
    }

    print(result.depth * result.distance)

    let result2 = results.reduce((depth: 0, distance: 0, aim: 0)) {
        state, route in
        var state = state
        switch route {
        case let .forward(num):
            state.distance += num
            state.depth += num * state.aim
        case let .up(num):
            state.aim -= num
        case let .down(num):
            state.aim += num
        }

        return state
    }

    print(result2.depth * result2.distance)
}
