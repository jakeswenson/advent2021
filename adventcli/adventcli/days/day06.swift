import Algorithms
import Collections
import Foundation
import Parsing

let parseFish = Int.parser()
let manyFish = Many(parseFish, separator: ",")

func runSim(_ fish: [Int], generation: Int) -> Int {
  let count = 9
  var generationalCounts: [Int] = Array(repeating: 0, count: count)

  for f in fish {
    generationalCounts[f] += 1
  }

  for _ in 0..<generation {
    let newFishCount = generationalCounts[0]
    for age in 1..<count {
      generationalCounts[age - 1] = generationalCounts[age]
    }
    generationalCounts[6] += newFishCount
    generationalCounts[8] = newFishCount
  }

  return generationalCounts.reduce(0, +)
}

let day06 = problem(day: 6) { input in
  let allFish = manyFish.parse(input.text)!

  part1(example: 5934, answer: 362639) {
    runSim(allFish, generation: 80)
  }

  part2(example: 26_984_457_539, answer: 1_639_854_996_917) {
    runSim(allFish, generation: 256)
  }
}
