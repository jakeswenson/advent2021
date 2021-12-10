import Algorithms
import Foundation

let day01 = problem(day: 1) { input in

    let lines = input.lines
    let numbers = lines.map { line in Int(line)! }

    part1(example: 7, answer: 1228) {
        zip(numbers, numbers[1...]).filter { fst, snd in snd > fst }.count
    }

    part2(example: 5, answer: 1257) {
        let windowed = numbers.windows(ofCount: 3).map { window in window.reduce(0, +) }
        return zip(windowed, windowed[1...]).filter { fst, snd in
            snd > fst
        }.count
    }
}
