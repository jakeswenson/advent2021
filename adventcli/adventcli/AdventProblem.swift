import Foundation

enum SolutionParts {
    case part1(_ result: Int)
    case part2(_ result: Int)
}

protocol Problem {
}

extension Problem {
    var problemId: String { String(format: "Day%02d", 3) }
}

struct Part1 {
    let computation: () -> Int
}

struct Solution: Problem {
    let part1: Part1
    let part2: Optional<() -> Int>
}

@resultBuilder struct ProblemPartBuilder {
    static func buildBlock(_ part1: Part1, _ part2: Optional<() -> Int> = Optional.none) -> Solution {
        Solution(part1: part1, part2: part2)
    }
    
}

func problem(day: Int, @ProblemPartBuilder parts: (String) -> Solution) -> () -> () {
    let file = String(format: "/code/advent2021/problems/problem%02d.txt", day)
    let path = URL(fileURLWithPath: file)
    let text = try! String(contentsOf: path)
    
    let solution: Solution = parts(text)
    
    // TODO: add all solutions to a list and automate running in main.swift (no let variables or calls)
    
    return {
        print(String(format: "===== DAY %02d =======", day))
        print("Part 1:", solution.part1.computation())
        print("Part 2:", (solution.part2 ?? { 0 })())
    }
}

func part1(_ logic: @escaping () -> Int) -> Part1 {
    return Part1(computation: logic)
}

func part2(_ logic: @escaping () -> Int) -> () -> Int {
    return logic
}
