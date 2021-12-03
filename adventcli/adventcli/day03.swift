import Foundation

func day03() {
    let file = "/code/personal/advent2021/adventcli/resources/problem03.txt"
    
    let path=URL(fileURLWithPath: file)
    let text=try! String(contentsOf: path)
    
    let lineArrays: [[Int]] = text.split(whereSeparator: \.isNewline)
        .map { line in
            line.map { Int("\($0)") ?? 0 }
        }
    
    let length = lineArrays[0].count
    
    let columns = (0...length-1)
    let rows = (0...lineArrays.count-1)
    
    func columnCounts(ints: [[Int]], column: Int) -> (zeros: Int, ones: Int) {
        return (0...ints.count-1).reduce((zeros: 0, ones:0), { counts, row in
            if ints[row][column] == 1 {
                return (zeros: counts.zeros, ones: counts.ones+1)
            } else {
                return (zeros: counts.zeros+1, ones: counts.ones)
            }
        })
    }
    
    let counts = columns.map { col in
        return columnCounts(ints: lineArrays, column: col)
    }
    
    let result = counts.reduce((gamma: 0, epsilon: 0), { state, counts in
        let new_gamma = (state.gamma << 1 | (counts.zeros > counts.ones ? 0 : 1))
        let new_epsilon = (state.epsilon << 1 | (counts.zeros < counts.ones ? 0 : 1))
        return (gamma: new_gamma, epsilon: new_epsilon)
    })
    
    print("Part 1:", result.gamma*result.epsilon)
    
    func binArrayToInt(binArray: [Int]) -> Int {
        binArray.reduce(0) { partialResult, bin in
            partialResult << 1 | bin
        }
    }
    
    let oxygenRatingArray = columns.reduce(lineArrays) { ints, column in
        if ints.count == 1 {
            return ints
        }
        let counts = columnCounts(ints: ints, column: column)
        return ints.filter { i in
            i[column] == (counts.ones == counts.zeros ? 1 : (counts.ones > counts.zeros ? 1 : 0))
        }
    }
    
    let oxygenRating = binArrayToInt(binArray: oxygenRatingArray[0])
    
    print("Part 2 - Oxygen:", oxygenRating)
    
    let co2RatingArray = columns.reduce(lineArrays) { ints, column in
        if ints.count == 1 {
            return ints
        }
        let counts = columnCounts(ints: ints, column: column)
        return ints.filter { i in
            i[column] == (counts.ones == counts.zeros ? 0 : (counts.ones < counts.zeros ? 1 : 0))
        }
    }
    
    let co2Rating = binArrayToInt(binArray: co2RatingArray[0])
    
    print("Part 2 - CO2:", co2Rating)
    
    
    print("Part:", co2Rating * oxygenRating)
}
