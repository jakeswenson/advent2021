import Foundation

func fetchProblem(day: Int) async throws -> Data {
    let value = ProcessInfo.processInfo.environment["ADVENT_API"]!

    let headers = ["Cookie": "session=\(value)"]

    let postData = NSData(data: "".data(using: String.Encoding.utf8)!)

    let url = URL(string: "https://adventofcode.com/2021/day/\(day)/input")!

    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
    request.httpMethod = "GET"
    request.allHTTPHeaderFields = headers
    request.httpBody = postData as Data

    let session = URLSession.shared
    let (data, _) = try await session.data(for: request)

    return data
}

func inputPath(_ inputName: String) -> String {
    "/code/advent2021/problems/\(inputName)"
}

func problemInputName(_ day: Int) -> String {
    String(format: "problem%02d.txt", day)
}

func loadProblem(day: Int) throws -> String {
    try loadProblemInput(path: inputPath(problemInputName(day)))
}

func loadProblemInput(path inputPath: String) throws -> String {
    let path = URL(fileURLWithPath: inputPath)
    return try String(contentsOf: path)
}

func writeProblemData(day: Int, _ data: Data) throws {
    let path = URL(fileURLWithPath: inputPath(problemInputName(day)))
    try data.write(to: path)
}
