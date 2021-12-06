import Algorithms
import Collections
import Foundation
import Parsing
import SwiftUI

let parseFish = Int.parser()
let manyFish = Many(parseFish, separator: ",")

let day06 = problem(day: 6) { text in
    let allFish = manyFish.parse(text)!

    part1 {
        var currentFish: [Int] = Array(repeating: 0, count: 9)

        for f in allFish {
            currentFish[f] += 1
        }

        for day in 0 ..< 80 {
            let newFishCount = currentFish[0]
            for age in 1 ..< currentFish.count {
                currentFish[age - 1] = currentFish[age]
            }
            currentFish[6] += newFishCount
            currentFish[currentFish.count - 1] = newFishCount
        }

        return currentFish.reduce(0, +)
    }

    part2 {
        var currentFish: [Int] = Array(repeating: 0, count: 9)

        for f in allFish {
            currentFish[f] += 1
        }

        for day in 0 ..< 256 {
            let newFishCount = currentFish[0]
            for age in 1 ..< currentFish.count {
                currentFish[age - 1] = currentFish[age]
            }
            currentFish[6] += newFishCount
            currentFish[currentFish.count - 1] = newFishCount
        }

        return currentFish.reduce(0, +)
    }
}
