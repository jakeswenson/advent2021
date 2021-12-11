import Foundation
import Algorithms
import Collections
import Foundation
import Parsing

func neighborsWithCornersIdx(_ nums: [[Int]], loc: Coord) -> [Coord] {
    let deltas = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1)            
    ]

    return deltas.compactMap { (dRow, dCol) in 
        let newRow = loc.row + dRow
        if newRow >= 0 && newRow < nums.count {
            let newCol = loc.col + dCol
            if newCol >= 0 && newCol < nums[newRow].count {
                return Coord(newRow, newCol)
            }
        }

        return nil
    }
}

func neighborsWithCorners(_ nums: [[Int]], loc: Coord) -> [(value: Int, coord: Coord)] {
    return neighborsWithCornersIdx(nums, loc: loc).map { idx in
        (value: nums[idx], coord: idx)
    }
}

func octopusFlash(_ nums: [[Int]]) -> (nextEnergyLevels: [[Int]], flashes: Int) {
    func increase(_ value: Int) -> Int { (value + 1) % 10 }

    var energyLevels: [[Int]] = nums.map { row in row.map(increase) }

    var searchQueue: Deque<Coord> = Deque(
        energyLevels.enumerated().flatMap { (row, rowValues) in 
            rowValues.enumerated().compactMap { (col, value) in 
                if value == 0 {
                    return Coord(row, col)
                }
                return nil
            }
        }
    ) 

    var visited: Set<Coord> = []

    while let loc = searchQueue.popFirst() {
        guard !visited.contains(loc) else {
            continue
        }
        visited.insert(loc)

        var triggered: [Coord] = []
        for neighbor in neighborsWithCorners(energyLevels, loc: loc) {
            let energyLevel = increase(energyLevels[neighbor.coord])
            if energyLevel == 0 {
                triggered.append(neighbor.coord)
            }

            energyLevels[neighbor.coord] = energyLevel
        }

        if !triggered.isEmpty {
            searchQueue.append(contentsOf: triggered)
        }
    }

    visited.forEach { coord in
        energyLevels[coord] = 0
    }

    return (nextEnergyLevels: energyLevels, flashes: visited.count)
}

let day11 = problem(day: 11) { input in
    let energylevels = input.lines.map { line in line.map { c in c.wholeNumberValue! } }
    
    part1(example: 1656, answer: 1739) {
        let result = (0..<100).reduce((energyLevels: energylevels, flashes: 0)) { curr, _ in
            let (nextEnergyLevels: levels, flashes: flashes) = octopusFlash(curr.energyLevels)

            return (energyLevels: levels, flashes: curr.flashes + flashes)
        }

        return result.flashes
    }

    part2(example: 195, answer: 324) {

        var iteration = 0
        var energylevels = energylevels

        while (!energylevels.allSatisfy { row in row.allSatisfy { $0 == 0 } }) {
            let (nextEnergyLevels: levels, _) = octopusFlash(energylevels)
            energylevels = levels
            iteration += 1
        }

        return iteration
    }
}
