import Foundation
import OrderedCollections

struct Part1 {
    let computation: () -> Int
}

struct Part2 {
    let computation: () -> Int
}

struct Solution {
    let part1: Part1
    let part2: Part2?
}

@resultBuilder enum ProblemPartBuilder {
    static func buildBlock(_ part1: Part1, _ part2: Part2? = Optional.none) -> Solution {
        Solution(part1: part1, part2: part2)
    }
}

struct Day {
    let day: Int
    let solution: Solution

    func display() {
        print(String(format: "======== DAY %02d ========", day))
        print("Part 1:", solution.part1.computation())
        print("Part 2:", solution.part2?.computation() ?? "<not implemented>" as Any)
        print()
    }
}

func problem(day: Int, @ProblemPartBuilder parts: (String) -> Solution) -> Day {
    let file = String(format: "/code/advent2021/problems/problem%02d.txt", day)
    let path = URL(fileURLWithPath: file)
    let text = try! String(contentsOf: path)

    let solution: Solution = parts(text)
    let day = Day(day: day, solution: solution)

    return day
}

func part1(_ logic: @escaping () -> Int) -> Part1 {
    Part1(computation: logic)
}

func part2(_ logic: @escaping () -> Int) -> Part2 {
    Part2(computation: logic)
}
