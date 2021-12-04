import Algorithms
import Foundation

let day01 = problem(day: 1) { text in

    let lines: [String.SubSequence] = text.split(whereSeparator: \.isNewline)
    let numbers = lines.map { line in Int(line) ?? 0 }

    part1 {
        zip(numbers, numbers[1...]).filter { fst, snd in snd > fst }.count
    }

    part2 {
        let windowed = numbers.windows(ofCount: 3).map { window in window.reduce(0, +) }
        return zip(windowed, windowed[1...]).filter { fst, snd in
            snd > fst
        }.count
    }
}
