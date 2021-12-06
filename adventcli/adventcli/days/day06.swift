import Algorithms
import Collections
import Foundation
import Parsing
import SwiftUI

struct Lanternfish {
    let state: UInt8
}

let parseFish = UInt8.parser()
let manyFish = Many(parseFish, separator: ",")

let day06 = problem(day: 6) { text in
    part1 {
        
        let allFish = manyFish.parse(text)!
        
        var currentFish: [UInt64] = Array(repeating: 0, count: 9)
        
        for f in allFish {
            currentFish[Int(f)] += 1
        }
        
        for day in (0..<80) {
            let newFishCount = currentFish[0]
            for age in (1..<currentFish.count) {
                currentFish[age-1] = currentFish[age]
            }
            currentFish[6] += newFishCount
            currentFish[currentFish.count-1] = newFishCount
        }
        
        let result = currentFish.reduce(0, +)
        
        return Int(result)
    }
    
    part2 {
        let allFish = manyFish.parse(text)!
        
        var currentFish: [UInt64] = Array(repeating: 0, count: 9)
        
        for f in allFish {
            currentFish[Int(f)] += 1
        }
        
        for day in (0..<256) {
            let newFishCount = currentFish[0]
            for age in (1..<currentFish.count) {
                currentFish[age-1] = currentFish[age]
            }
            currentFish[6] += newFishCount
            currentFish[currentFish.count-1] = newFishCount
        }
        
        let result = currentFish.reduce(0, +)
        
        return Int(result)
    }
}
