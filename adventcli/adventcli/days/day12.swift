import Algorithms
import Collections
import DequeModule
import Foundation
import OrderedCollections

typealias Node = String.SubSequence
typealias Graph = OrderedDictionary<Node, OrderedSet<Node>>

let start: Node = "start"[...]
let end: Node = "end"[...]

extension Node {
  var isBig: Bool {
    allSatisfy(\.isUppercase)
  }

  var isSmall: Bool {
    allSatisfy(\.isLowercase)
  }
}

struct Edge: Hashable, Equatable {
  let source: Node
  let target: Node
}

func countWaysToEnd(_ graph: Graph, from entry: Node) -> Int {

  typealias SearchPair = (edge: Node, from: [Node], visited: Set<Node>)

  var search: Deque<SearchPair> = [
    entry.isBig
      ? (edge: entry, from: [], visited: [])
      : (edge: entry, from: [], visited: [entry])
  ]

  var endCount = 0

  while let (edge, from, visited) = search.popLast() {
    var visited = visited

    if edge == start {
      continue
    }

    if edge == end {
      endCount += 1
      continue
    }

    if !edge.isBig {
      visited.insert(edge)
    }

    let options: [SearchPair] = graph[edge]!.filter { !visited.contains($0) && $0 != start }
      .map { next in
        var from = from
        from.append(edge)

        return (edge: next, from: from, visited: visited)
      }

    search.append(contentsOf: options)
  }

  return endCount
}

func countWaysToEndTwice(_ graph: Graph, from entry: Node) -> Int {
  struct SearchPair: CustomDebugStringConvertible {
    let edge: Node
    let from: [Node]
    let visited: Set<Node>
    let hasUnrecoredVisit: Bool

    var debugDescription: String {
      "\(from)::\(edge)"
    }
  }

  var frontier: Deque<SearchPair> = [
    SearchPair(edge: entry, from: [], visited: [], hasUnrecoredVisit: false)
  ]

  var paths: OrderedSet<[Node]> = []

  while let current = frontier.popLast() {
    let edge = current.edge

    if edge == start {
      continue
    }

    let visited = current.visited
    let hasUnrecoredVisit = current.hasUnrecoredVisit

    if edge == end {
      paths.append(current.from)
      // let from = current.from.joined(separator: ",")
      // print("\(from),\(edge) (\(paths.count)) :: \(visited) -- \(hasUnrecoredVisit)")
      continue
    }

    var from = current.from
    from.append(edge)

    let nothingVisited = Set(visited)

    let edges = graph[edge]!.filter { !visited.contains($0) && $0 != start }

    if edge.isBig {
      let nextNodes: [SearchPair] =
        edges.map { next in
          return SearchPair(
            edge: next,
            from: from,
            visited: nothingVisited,
            hasUnrecoredVisit: hasUnrecoredVisit)
        }

      frontier.append(contentsOf: nextNodes)

    } else if edge.isSmall {

      var newVisited = visited
      newVisited.insert(edge)

      if hasUnrecoredVisit {
        // EDGE is small, but someone above has already skip being marked visited...
        // just act normal

        let nextNodes: [SearchPair] = edges.map { next in
          return SearchPair(edge: next, from: from, visited: newVisited, hasUnrecoredVisit: true)
        }

        frontier.append(contentsOf: nextNodes)
      } else {
        // EDGE is small, time to act normal + claim skip recording

        let normalNodes: [SearchPair] = edges.map { next in
          return SearchPair(edge: next, from: from, visited: newVisited, hasUnrecoredVisit: false)
        }

        frontier.append(contentsOf: normalNodes)

        // print("Normal", normalNodes)

        let revisitableNodes: [SearchPair] = graph[edge]!
          .filter { !visited.contains($0) && $0 != start && $0 != end }
          .map { next in
            return SearchPair(
              edge: next, from: from, visited: nothingVisited, hasUnrecoredVisit: true)
          }

        // print("Revisitable from \(edge): ", revisitableNodes)

        frontier.append(contentsOf: revisitableNodes)
      }
    }
  }

  return paths.count
}

let day12 = problem(day: 12) { input in
  let edges: [Edge] = input.lines.map {
    let edge = $0.split(separator: "-")
    return Edge(source: edge[0], target: edge[1])
  }

  let graph: Graph = {
    var graph: Graph = [:]

    for edge in edges {
      graph[edge.source, default: []].append(edge.target)
      graph[edge.target, default: []].append(edge.source)
    }

    return graph
  }()

  part1(example: 10, answer: 4549) {
    var search: Deque<Node> = Deque()

    var endCount = graph[start]!.reduce(0) { waysToEnd, node in
      let count = countWaysToEnd(graph, from: node)
      print("\(count) ways to end from \(node)")
      return waysToEnd + count
    }

    return endCount
  }

  part2(example: 36, answer: 120535) {
    print()

    var endCount = graph[start]!.reduce(0) { waysToEnd, node in
      let count = countWaysToEndTwice(graph, from: node)
      print("\(count) ways to end from \(node)")

      return waysToEnd + count
    }

    return endCount

  }
}
