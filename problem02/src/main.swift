import Foundation
import Algorithms
import Parsing

let file = "advent2021/problem02/resources/data.txt"
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

