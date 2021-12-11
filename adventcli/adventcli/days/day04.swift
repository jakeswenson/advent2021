import Foundation
import Parsing

struct BingoBoard {
  let numbers: Set<Int>
  let rows: [Set<Int>]
  let columns: [Set<Int>]

  init(board: [[Int]]) {
    numbers = Set(board.flatMap { $0 })
    assert(board.count == 5, "BINGO boards should always have 5 rows")

    let bingoIdexes = (0..<5)

    rows = bingoIdexes.map { row in
      assert(board[row].count == 5, "Rows should always have 5 columns")

      return Set(
        bingoIdexes.map { col in
          board[row][col]
        })
    }

    columns = bingoIdexes.map { col in
      Set(
        bingoIdexes.map { row in
          board[row][col]
        })
    }
  }

  func hasWon(_ nums: Set<Int>) -> Bool {
    (rows + columns).contains { rowOrColumn in
      rowOrColumn.isSubset(of: nums)
    }
  }
}

let rowParser = Many(
  Int.parser(), atLeast: 5, atMost: 5, separator: Whitespace<Substring.UTF8View>())
let parser = Many(rowParser, atLeast: 5, atMost: 5, separator: Whitespace())
  .map { board in BingoBoard(board: board) }
let manyBoards = Many(parser, separator: Whitespace())

let problemParser = Many(Int.parser(), separator: ",".utf8)
  .skip(Whitespace())
  .take(manyBoards)

let day04 = problem(day: 4) { input in
  let (nums, boards) = problemParser.parse(input.utf8)!

  part1(example: 4512, answer: 60368) {
    print("Called Number Count", nums.count)
    print("Boards Count", boards.count)

    struct ReducerState {
      let calledNumbers: Set<Int>
      let lastNum: Int?
      let board: BingoBoard?

      static let InitialState = ReducerState(calledNumbers: [], lastNum: nil, board: nil)
    }

    let result = nums.reduce(ReducerState.InitialState) { state, num in
      if state.board != nil {
        return state
      }

      var calledNumbers = state.calledNumbers
      calledNumbers.insert(num)

      let winner = boards.first { board in board.hasWon(calledNumbers) }

      return ReducerState(calledNumbers: calledNumbers, lastNum: num, board: winner)
    }

    let boardNums = result.board!.numbers
    let unmarkedNumbersSum = boardNums.subtracting(result.calledNumbers).reduce(0, +)

    return unmarkedNumbersSum * result.lastNum!
  }

  part2(example: 1924, answer: 17435) {
    struct BoardWin {
      let board: BingoBoard
      let winningNumber: Int
    }

    struct ReducerState {
      let calledNumbers: Set<Int>
      let remainingBoards: Array<BingoBoard>.SubSequence
      let winners: [BoardWin]

      static func initial(allBoards: [BingoBoard]) -> ReducerState {
        ReducerState(calledNumbers: [], remainingBoards: allBoards[...], winners: [])
      }
    }

    let result = nums.reduce(ReducerState.initial(allBoards: boards)) { state, num in
      var calledNumbers = state.calledNumbers
      var remainingBoards = state.remainingBoards

      if remainingBoards.isEmpty {
        return state
      }

      var winners = state.winners

      calledNumbers.insert(num)

      let p = remainingBoards.partition { board in
        board.hasWon(calledNumbers)
      }

      let newWinners = remainingBoards[p...].map { board in
        BoardWin(board: board, winningNumber: num)
      }

      winners.append(contentsOf: newWinners)

      return ReducerState(
        calledNumbers: calledNumbers, remainingBoards: remainingBoards[..<p], winners: winners)
    }

    let lastWinner = result.winners.last!

    let boardNums = lastWinner.board.numbers
    let unmarkedNumbersSum = boardNums.subtracting(result.calledNumbers).reduce(0, +)

    return unmarkedNumbersSum * lastWinner.winningNumber
  }
}

func testBoardParsing() {
  let board = """
    83 40 67 98  4
    50 74 31 30  3
    75 64 79 61  5
    12 59 26 25 72
    36 33 18 54 10

    68 56 28 57 12
    78 66 20 85 51
    35 23  7 99 44
    86 37  8 45 49
    40 77 32  6 88

    75 15 20 79  8
    81 69 54 33 28
     9 53 48 95 27
    65 84 40 71 36
    13 31  6 68 29

    94  6 30 16 74
    91 47 66 31 90
    14 56 45 55 20
    58 70 27 46 73
    77 67 97 51 54
    """.trimmingCharacters(in: .whitespacesAndNewlines)

  print(rowParser.parse("83 40 67 98 4".utf8)!)

  print("Parsed Bingo Board", manyBoards.parse(board.utf8)?.count ?? "<fail>" as Any)
}
