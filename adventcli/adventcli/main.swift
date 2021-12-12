import ArgumentParser
import Foundation

let days = [
  day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day11, day12,
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
    subcommands: [Run.self, Problem.self, Today.self, Fetch.self],

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

struct Problem: ParsableCommand {
  @Argument(help: "The day to run")
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

struct Today: ParsableCommand {
  @Flag(help: "Use sample input")
  var sample: Bool = false

  func run() throws {
    let latestDay = days.max { d1, d2 in d1.day < d2.day }!

    let sampleFile = String(format: "%02d.sample", latestDay.day)

    try latestDay.solve(input: (sample ? try loadProblemInput(path: inputPath(sampleFile)) : nil))

    print("Done!")
  }
}

func done() {
  exit(0)
}

struct Fetch: ParsableCommand {

  @Argument(help: "The day to fetch")
  var day: Int?

  func run() throws {
    let day = day ?? days.max { d1, d2 in d1.day < d2.day }!.day
    print("Fetching problem input for day \(day)...")
    Task.init {
      do {
        let data = try await fetchProblem(day: day)
        print("Fetched problem data, writing to file...")
        try writeProblemData(day: day, data)
        print("Done")
        done()
      } catch AdventError.noApiToken {
        print("No ADEVENT_API token found, set it with:")
        print("  export ADVENT_API='TOKEN'")
      } catch {
        print("Failed to fetch")
      }

      abort()
    }

    dispatchMain()
  }
}

Advent.main()
