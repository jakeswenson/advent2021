import ArgumentParser
import Foundation

let days = [
    day01, day02, day03, day04, day05, day06
]

struct Advent: ParsableCommand {
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "Advent of code 2021",

        // Commands can define a version for automatic '--version' support.
        version: "2021",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Run.self, Solve.self, Fetch.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Run.self
    )
}

struct Run: ParsableCommand {
    @Argument(help: "The days to run")
    var daysToRun: [Int] = []

    func run() throws {
        for day in days {
            if daysToRun.isEmpty || daysToRun.contains(day.day) {
                do {
                    try day.solve()
                } catch {
                    print("Failed to run day \(day.day)")
                }
            }
        }

        print("Done!")
    }
}

struct Solve: ParsableCommand {
    @Argument(help: "The days to run")
    var dayToRun: Int

    @Argument(help: "File name of the input to run against")
    var inputName: String?

    func run() throws {
        try days.filter {
            $0.day == dayToRun
        }.first?.solve(input: inputName.map { try loadProblemInput(path: inputPath($0)) })

        print("Done!")
    }
}

func done() {
    exit(0)
}

struct Fetch: ParsableCommand {
    @Argument(help: "The day to fetch")
    var day: Int

    func run() throws {
        print("Fetching problem input for day \(day)...")
        Task.init {
            do {
                let data = try await fetchProblem(day: day)
                print("Fetched problem data, writing to file...")
                try writeProblemData(day: day, data)
                print("Done")
            } catch {
                print("Failed to fetch")
            }

            done()
        }

        dispatchMain()
    }
}

Advent.main()
