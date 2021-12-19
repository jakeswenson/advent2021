import Collections
import Algorithms
import Parsing


let ws = Whitespace()

let parseRange = Int.parser().skip("..".utf8).take(Int.parser()).map { $0...$1 }
let day17Parser = Skip("target area:".utf8).skip(ws).skip("x=".utf8)
  .take(parseRange)
  .skip(",".utf8).skip(ws).skip("y=".utf8)
  .take(parseRange)

func maxDistance(_ dist: Int) -> Int {
  ((dist+1)*dist)/2
}

let day17 = problem(day: 17) { input in
  let (xRange, yRange) = day17Parser.parse(input.utf8)!
  let minY = yRange.min()!
  let maxY = maxDistance(minY)

  part1(example: 45, answer: 30628) {
    return maxY
  }


  part2(example: 112, answer: 30628) {
    return (1...xRange.upperBound).reduce(Set<Coord>()) { results, initX in
      if maxDistance(initX) < xRange.lowerBound {
        return results
      }

      return (yRange.lowerBound...maxY).reduce(results) { results, initY in
        var results = results
        var xVelocity = initX, yVelocity = initY
        var xPos = 0, yPos = 0

        while xPos <= xRange.upperBound && yPos >= yRange.lowerBound {
          if xPos >= xRange.lowerBound && yPos <= yRange.upperBound {
            results.insert(Coord(initX, initY))
            break
          }

          xPos += xVelocity
          yPos += yVelocity

          yVelocity-=1
          xVelocity = max(xVelocity-1, 0)
        }


        return results
      }
    }.count
  }
}
