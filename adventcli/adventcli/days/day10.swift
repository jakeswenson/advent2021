import Algorithms
import Collections
import Foundation
import Parsing

extension Character {
  var opposite: Character? {
    switch self {
    case "(": return ")"
    case ")": return "("
    case "<": return ">"
    case ">": return "<"
    case "[": return "]"
    case "]": return "["
    case "{": return "}"
    case "}": return "{"
    default: return nil
    }
  }
}

enum ParseError: Error {
  case unexpected(_ char: Character)
  case expected(_ expected: Character, got: Character)
}

struct Chunks {
  let openedChunks: [Character]

  init(_ chunks: [Character] = []) {
    openedChunks = chunks
  }

  func update(withNext char: Character) throws -> Self {
    var openedChunks = openedChunks
    switch char {
    case "(", "[", "<", "{": openedChunks.append(char)
    case ")", "]", ">", "}":
      let opening = openedChunks.popLast()!
      let expected = char.opposite!
      if opening != expected {
        throw ParseError.expected(expected, got: char)
      }

    default:
      throw ParseError.unexpected(char)
    }

    return Self(openedChunks)
  }

  static let initial = Chunks()
}

let day10 = problem(day: 10) { input in
  let lines = input.lines

  part1(example: 26397, answer: 366027) {
    let result = try! lines.reduce(0) { score, line in
      do {
        let _ = try line.reduce(Chunks.initial) { chunks, char in
          try chunks.update(withNext: char)
        }
      } catch (ParseError.expected(_, let got)) {
        switch got {
        case ")": return score + 3
        case "]": return score + 57
        case "}": return score + 1197
        case ">": return score + 25137
        default:
          break
        }
      }

      return score
    }

    return result
  }

  part2(example: 288957, answer: 1_118_645_287) {
    var result: [Int] = try! lines.compactMap { line in
      do {
        let opened = try line.reduce(Chunks.initial) { chunks, char in
          try chunks.update(withNext: char)
        }

        let score = opened.openedChunks.reversed().reduce(0) { s, char in
          let newS = s * 5

          switch char.opposite! {
          case ")": return newS + 1
          case "]": return newS + 2
          case "}": return newS + 3
          case ">": return newS + 4
          default:
            break
          }

          return s
        }

        return score
      } catch (ParseError.expected(_, _)) {
        // ignored for part 2
      }

      return nil
    }

    result.sort()

    return result[result.count / 2]
  }
}
