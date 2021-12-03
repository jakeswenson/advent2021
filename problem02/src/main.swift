import Foundation
import Algorithms
import Parsing

let file = "/code/advent2021/problems/problem02.txt"
let path=URL(fileURLWithPath: file)
let text=try! String(contentsOf: path)


enum Route {
    case forward(num:Int)
    case up(num:Int)
    case down(num:Int)
}

let direction = StartsWith("forward").map { Route.forward(num:) }
  .orElse(StartsWith("up").map { Route.up(num:) })
  .orElse(StartsWith("down").map { Route.down(num:) })
  .skip(" ")
  .take(Int.parser())
  .map { $0($1) }

let directions = Many(direction, separator: "\n")

print(directions.parse(text) ?? [])

