import Algorithms
import Collections
import Foundation
import Parsing

struct Point: Equatable, Hashable {
    let x: UInt16, y: UInt16
}

struct Line {
    let start: Point, end: Point

    var isHorizontal: Bool { start.y == end.y }
    var isVertical: Bool { start.x == end.x }

    func pointsOnLine() -> [Point] {
        if isVertical {
            let (minY, maxY) = [start.y, end.y].minAndMax()!
            return (minY ... maxY).map { Point(x: start.x, y: $0) }
        } else if isHorizontal {
            let (minX, maxX) = [start.x, end.x].minAndMax()!
            return (minX ... maxX).map { Point(x: $0, y: start.y) }
        }

        let xs = stride(from: start.x, through: end.x, by: end.x < start.x ? -1 : 1)
        let ys = stride(from: start.y, through: end.y, by: end.y < start.y ? -1 : 1)

        return zip(xs, ys).map { Point(x: $0, y: $1) }
    }
}

let parsePoint = UInt16.parser().skip(",".utf8).take(UInt16.parser())
    .map { x, y in Point(x: x, y: y) }

let lineParser = parsePoint.skip(Whitespace()).skip("->".utf8).skip(Whitespace()).take(parsePoint)
    .map { start, end in Line(start: start, end: end) }

let lines = Many(lineParser, separator: Whitespace())

let day05 = problem(day: 5) { text in
    let allLines = lines.parse(text.utf8)!

    part1 {
        print("Parsed Lines", allLines.count)

        let part1Lines = allLines.filter { line in line.isHorizontal || line.isVertical }

        print("Part1 Lines", part1Lines.count)

        var counts: [Point: UInt8] = [:]

        for p in part1Lines.flatMap({ $0.pointsOnLine() }) {
            counts[p, default: 0] += 1
        }

        let intersections = counts.values.filter { $0 >= 2 }.count

        return intersections
    }

    part2 {
        var counts: [Point: UInt8] = [:]

        for p in allLines.flatMap({ $0.pointsOnLine() }) {
            counts[p, default: 0] += 1
        }

        let intersections = counts.values.filter { $0 >= 2 }.count

        return intersections
    }
}
