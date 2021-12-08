import Algorithms
import Collections
import Foundation
import Parsing

let numberSizes = [
    0: 6,
    1: 2,
    2: 5,
    3: 5,
    4: 4,
    5: 5,
    6: 6,
    7: 3,
    8: 7,
    9: 6
]

let day08 = problem(day: 8) { text in
    let notes: [(signals: [String.SubSequence], outputs: [String.SubSequence])] = text.split(whereSeparator: \.isNewline)
        .map { line in
            let parts = line.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
            let (signalsRaw, outputsRaw) = (parts[0], parts[1])

            let signals = signalsRaw.split(separator: " ", omittingEmptySubsequences: false)
            let outputs = outputsRaw.split(separator: " ", omittingEmptySubsequences: false)

            return (signals: signals, outputs: outputs)
        }

    part1 {
        let numberLengths: [Int] = ([1, 4, 7, 8].map { numberSizes[$0]! })

        let result =
            notes.flatMap { $0.outputs }
                .filter { numberLengths.contains($0.count) }
                .count

        return result
    }

    part2 {
        let numberLengths: [Int] = ([1, 4, 7, 8].map { numberSizes[$0]! })

        func matchDigit(_ chars: [Set<Character>], by: (Set<Character>) -> Bool) -> (Set<Character>, Array<Set<Character>>.SubSequence) {
            var chars = chars
            let partitionIdx = chars.partition { !by($0) }

            let first = chars[..<partitionIdx]
            assert(first.count == 1)
            return (first[0], chars[partitionIdx...])
        }

        let result = notes.map { note in 

            let signalMap = Dictionary(uniqueKeysWithValues: note.signals
                .filter { numberLengths.contains($0.count) }
                .map { ($0.count, $0) })

            let one = Set(signalMap[numberSizes[1]!]!)
            let four = Set(signalMap[numberSizes[4]!]!)
            let seven = Set(signalMap[numberSizes[7]!]!)
            let eight = Set(signalMap[numberSizes[8]!]!)
            let known = [one, four, seven, eight]

            let upperL = four.subtracting(one)
            let top = seven.subtracting(one)

            let unknownSignals = note.signals.map{ Set($0) }.filter { signal in
                !known.contains { k in k == signal }
            }

            let nineMatcher = upperL.union(top).union(one)

            let (nine, remaining) = matchDigit(unknownSignals) { sig in 
                nineMatcher.isStrictSubset(of: sig)
            }

            let zeroOrThree = remaining.filter { seven.isStrictSubset(of: $0) }

            let zero = zeroOrThree.first {
                eight.subtracting($0).count == 1
            }!

            let three = zeroOrThree.first {
                eight.subtracting($0).count == 2
            }!

            // zero, one, three, four, seven, eight, nine
            // - need 2, 5, 6

            let twoFiveSix = remaining.filter { zero != $0 && three != $0 }

            let (two, fiveSix) = matchDigit(twoFiveSix) { option in
                upperL.subtracting(option).count == 1
            }

            let six = fiveSix.first { option in 
                eight.subtracting(option).count == 1
            }

            let five = fiveSix.first { option in 
                eight.subtracting(option).count == 2
            }

            func digit(_ output: Set<Character>) -> Int {
                if zero == output { return 0 }
                if one == output { return 1 }
                if two == output { return 2 }
                if three == output { return 3 }
                if four == output { return 4 }
                if five == output { return 5 }
                if six == output { return 6 }
                if seven == output { return 7 }
                if eight == output { return 8 }
                return 9
            }

            let number = note.outputs.map { Set($0) }.reduce(0) { state, output in 
                (10*state) + digit(output)
            }

            return number
        }.reduce(0, +)

        return result
    }
}
