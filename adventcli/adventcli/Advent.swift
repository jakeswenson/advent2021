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
    let (data, response) = try await session.data(for: request)

    print(data)
    
    return data
}

func loadProblem(day: Int) throws -> String  {
    let file = String(format: "/code/advent2021/problems/problem%02d.txt", day)
    let path = URL(fileURLWithPath: file)
    return try String(contentsOf: path)
}

func writeProblemData(day: Int, _ data: Data) throws {
    let file = String(format: "/code/advent2021/problems/problem%02d.txt", day)
    let path = URL(fileURLWithPath: file)
    try data.write(to: path)
}
