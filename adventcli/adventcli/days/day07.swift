import Algorithms
import Collections
import Foundation
import Parsing

let crabPosition = Int.parser()
let crabPositions = Many(crabPosition, separator: ",")

let day07 = problem(day: 7) { text in
    let positions = crabPositions.parse(text)!
    let max = positions.max()!

    part1 {

        let result = (0...max).reduce(Int.max) { currentMin, targetPosition in 
            min(currentMin, positions.reduce(0) { total, pos in
                total + abs(pos-targetPosition)
            })
        }

        return result
    }

    part2 {

        let result = (0...max).reduce(Int.max) { currentMin, targetPosition in 
            min(currentMin, positions.reduce(0) { total, pos in
                let n = abs(pos-targetPosition)
                return total + (((n+1)*n)/2)
            })
        }

        return result
    }
}
