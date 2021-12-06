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
        var allFish = manyFish.parse(text)!
        
        let fish = (0..<80).reduce(allFish) { currentFish, day in
            var currentFish = currentFish
            // print(currentFish)
            
            var newFish: [UInt8] = []
            for idx in (0..<currentFish.count) {
                if currentFish[idx] == 0 {
                    currentFish[idx] = 7
                    newFish.append(8)
                }
                currentFish[idx] -= 1
                let value = currentFish[idx]
                
            }
            
            currentFish.append(contentsOf: newFish)
            
            return currentFish
        }
        
        return fish.count
    }
    
    part2 {
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
}
