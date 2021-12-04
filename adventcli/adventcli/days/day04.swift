import Foundation
import Parsing

struct BingoBoard {
    let numbers: Set<Int>
    let rows: [Set<Int>]
    let columns: [Set<Int>]

    private init(board: [[Int]]) {
        numbers = Set(board.flatMap { $0 })
        assert(board.count == 5)

        let bingoIdexes = (0 ... 4)

        rows = bingoIdexes.map { row in
            Set(bingoIdexes.map { col in
                board[row][col]
            })
        }

        columns = bingoIdexes.map { col in
            Set(bingoIdexes.map { row in
                board[row][col]
            })
        }
    }

    func hasWon(_ nums: Set<Int>) -> Bool {
        (rows + columns).contains { rowOrColumn in
            rowOrColumn.isSubset(of: nums)
        }
    }

    static let rowParser = Many(Int.parser(), atLeast: 5, atMost: 5, separator: Prefix<Substring.UTF8View> { byte in
        byte == .init(ascii: " ")
    })
    static let parser =
        Many(
            rowParser,
            atLeast: 5,
            atMost: 5,
            separator: Whitespace()
        ).map { board in BingoBoard(board: board) }

    static let manyBoards = Many(BingoBoard.parser, separator: Whitespace())
}

let problemParser = Many(Int.parser(), separator: ",".utf8)
    .skip(Whitespace())
    .take(BingoBoard.manyBoards)

let day04 = problem(day: 4) { text in
    let (nums, boards) = problemParser.parse(text.utf8).unsafelyUnwrapped

    part1 {
        print("Called Number Count", nums.count)
        print("Boards Count", boards.count)

        struct ReducerState {
            let nums: Set<Int>
            let lastNum: Int?
            let board: BingoBoard?

            init(nums: Set<Int> = [], lastNum: Int? = nil, board: BingoBoard? = nil) {
                self.nums = nums
                self.lastNum = lastNum
                self.board = board
            }
        }

        let result = nums.reduce(ReducerState()) { state, num in
            if state.board != nil {
                return state
            }

            var nums = state.nums

            nums.insert(num)

            let winner = boards.first { board in
                board.hasWon(nums)
            }

            return ReducerState(nums: nums, lastNum: num, board: winner)
        }

        let boardNums = result.board?.numbers ?? Set()

        return boardNums.subtracting(result.nums).reduce(0, +) * (result.lastNum ?? 0)
    }

    part2 {
        typealias ReducerState = (Set<Int>, Array<BingoBoard>.SubSequence, [(Int, BingoBoard)])

        let (calledNumbers, boards, winners): ReducerState = nums.reduce((Set<Int>(), boards[...], [])) { state, num in
            var nums = state.0
            var boards = state.1

            if boards.isEmpty {
                return state
            }

            var winners = state.2

            nums.insert(num)

            let p = boards.partition { board in
                board.hasWon(nums)
            }

            let newWinners = boards[p...].map { board in
                (num, board)
            }

            winners.append(contentsOf: newWinners)

            return (nums, boards[..<p], winners)
        }

        let lastWinner = winners.last

        let boardNums = lastWinner?.1.numbers ?? Set()

        return boardNums.subtracting(calledNumbers).reduce(0, +) * (lastWinner?.0 ?? 0)
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

    print(BingoBoard.rowParser.parse("83 40 67 98 4".utf8) ?? [])

    print("Parsed Bingo Board", BingoBoard.manyBoards.parse(board.utf8)?.count ?? "<fail>" as Any)
}
