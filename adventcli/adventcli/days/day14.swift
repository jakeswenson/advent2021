import Algorithms
import Parsing

struct Day14Pair: Hashable, Equatable, CustomDebugStringConvertible {
  let fst: String, snd: String

  var debugDescription: String {
    "\(fst)\(snd)"
  }
}

let templateParser = AdventParsers.line.map {
  Array($0.map { Character(UnicodeScalar($0)) }.map(String.init))
}

let productionRulesParser = AdventParsers.char.take(AdventParsers.char)
  .skip(Whitespace()).skip("->".utf8).skip(Whitespace())
  .take(AdventParsers.char)
  .map { (Day14Pair(fst: $0, snd: $1), $2) }

let manyRulesParser = Many(productionRulesParser, separator: Whitespace())

let problem14Parser = templateParser.skip(Whitespace()).take(manyRulesParser)

let day14 = problem(day: 14) { input in
  let (template, rules) = problem14Parser.parse(input.utf8)!

  let rulesMap: [Day14Pair: String] = Dictionary(uniqueKeysWithValues: rules)

  part1(example: 1588, answer: 2947) {

    let result = (0..<10).reduce(Array(template)) { template, step in
      return zip(template, (template + ["_"])[1...]).flatMap { fst, snd -> [String] in
        if let production: String = rulesMap[Day14Pair(fst: fst, snd: snd)] {
          return [fst, production]
        } else {
          return [fst]
        }
      }
    }

    let counts = result.elementCounts()

    let (min, max) = counts.keys.minAndMax {
      counts[$0]! < counts[$1]!
    }!

    return counts[max]! - counts[min]!
  }

  part2(example: 2_188_189_693_529, answer: 3_232_426_226_464) {

    let initialCounts = zip(template, template[1...]).map { Day14Pair(fst: $0, snd: $1) }
      .elementCounts()

    let results = (0..<40).reduce(initialCounts) { counts, step in
      counts.flatMap { (k, v) in
        return rulesMap[k].flatMap { production in
          [
            (Day14Pair(fst: k.fst, snd: production), v),
            (Day14Pair(fst: production, snd: k.snd), v),
          ]
        } ?? []
      }.reduce([Day14Pair: Int]()) {
        (counts: [Day14Pair: Int], pair: (Day14Pair, Int)) -> [Day14Pair: Int] in
        return counts.merging([pair], uniquingKeysWith: +)
      }
    }

    let counts = results.map { kv in (kv.0.snd, kv.1) }
      .reduce([String: Int]()) { counts, letter_value in
        return counts.merging([letter_value], uniquingKeysWith: +)
      }

    let (min, max) = counts.minAndMax {
      $0.1 < $1.1
    }!

    print("Min:", min, "Max:", max)

    return max.1 - min.1
  }
}
