import Algorithms
import Foundation

let file = "/code/advent2021/problems/problem01.txt"
let path = URL(fileURLWithPath: file)
let text = try! String(contentsOf: path)

let lines: [String.SubSequence] = text.split(whereSeparator: \.isNewline)

let numbers = lines.map { line in Int(line) ?? 0 }

let count = zip(numbers, numbers[1...]).filter { fst, snd in
    snd > fst
}.count

print(count)

// part2
let windowed = numbers.windows(ofCount: 3).map { window in window.reduce(0, +) }
let answer2 = zip(windowed, windowed[1...]).filter { fst, snd in
    snd > fst
}.count

print(answer2)
