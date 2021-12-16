import Algorithms
import Collections
import CoreFoundation
import Parsing

struct Header {
  let version: UInt8, type: UInt8

  static func parse(_ stream: BitStream) -> Header {
    let versionBits = stream[..<(stream.startIndex + 3)]
    let version = versionBits.reduce(UInt8.zero) { n, bit in n << 1 | bit }
    // print("Version", versionBits, version)

    let typeBits = stream[(stream.startIndex + 3)..<(stream.startIndex + 6)]
    let type = typeBits.reduce(UInt8.zero) { n, bit in n << 1 | bit }
    // print("Type:", typeBits, type)

    return Header(version: version, type: type)
  }
}

typealias BitStream = ArraySlice<UInt8>

func parseVarInt(_ stream: BitStream) -> (Int, BitStream) {
  var stream = stream
  var int = Int.zero

  while let chunk = Optional.some(stream.prefix(5)) {
    // print("Chunk", chunk, "start", chunk.startIndex, "end", chunk.endIndex)
    assert(!chunk.isEmpty)
    int = chunk[(stream.startIndex + 1)...].reduce(int) { n, bit in n << 1 | Int(bit) }

    stream = stream[chunk.endIndex...]

    if chunk[chunk.startIndex] == 0 {
      break
    }
  }

  return (int, stream)
}

func parseSubPackets(_ rest: BitStream) -> ([BitsPacket], BitStream) {
  // print("Operator", rest)
  if rest.first! == 0 {
    let subPacketsSize = rest[(rest.startIndex + 1)...(rest.startIndex + 15)].reduce(Int.zero) {
      n, bit in n << 1 | Int(bit)
    }

    var subPackets = rest[(rest.startIndex + 16)..<(rest.startIndex + 16 + subPacketsSize)]
    var packets: [BitsPacket] = []

    while !subPackets.isEmpty {
      let (packet, rest) = BitsPacket.parse(bitStream: subPackets)!
      packets.append(packet)
      subPackets = rest
    }

    let sub = rest[(rest.startIndex + 16 + subPacketsSize)...]

    return (packets, sub)
  } else {
    let numSubPackets = rest[(rest.startIndex + 1)...(rest.startIndex + 11)].reduce(Int.zero) {
      n, bit in n << 1 | Int(bit)
    }

    let subPackets = rest[(rest.startIndex + 12)...]
    var packets: [BitsPacket] = []

    let rest = (0..<numSubPackets).reduce(subPackets) { subPackets, _ in
      let (packet, rest) = BitsPacket.parse(bitStream: subPackets)!
      packets.append(packet)
      return rest
    }

    return (packets, rest)
  }
}

enum BitsPacket: Equatable {

  case literal(version: UInt8, _ value: Int)
  case sum(version: UInt8, _ packets: [BitsPacket])
  case product(version: UInt8, _ packets: [BitsPacket])
  case minimum(version: UInt8, _ packets: [BitsPacket])
  case maximum(version: UInt8, _ packets: [BitsPacket])
  case greaterThan(version: UInt8, _ packets: [BitsPacket])
  case lessThan(version: UInt8, _ packets: [BitsPacket])
  case equalTo(version: UInt8, _ packets: [BitsPacket])

  var type: UInt8 {
    switch self {
    case .sum(_, _): return 0
    case .product(_, _): return 1
    case .minimum(_, _): return 2
    case .maximum(_, _): return 3
    case .literal(_, _): return 4
    case .greaterThan(_, _): return 5
    case .lessThan(_, _): return 6
    case .equalTo(_, _): return 7
    }
  }

  static func parse(bitStream: BitStream) -> (BitsPacket, BitStream)? {
    // print("Stream", bitStream)

    let header = Header.parse(bitStream)

    let rest = bitStream[(bitStream.startIndex + 6)...]

    switch header.type {
    case 0:
      let (packets, rest) = parseSubPackets(rest)
      return (.sum(version: header.version, packets), rest)
    case 1:
      let (packets, rest) = parseSubPackets(rest)
      return (.product(version: header.version, packets), rest)
    case 2:
      let (packets, rest) = parseSubPackets(rest)
      return (.minimum(version: header.version, packets), rest)
    case 3:
      let (packets, rest) = parseSubPackets(rest)
      return (.maximum(version: header.version, packets), rest)
    case 4:
      let (value, rest) = parseVarInt(rest)
      return (.literal(version: header.version, value), rest)
    case 5:
      let (packets, rest) = parseSubPackets(rest)
      return (.greaterThan(version: header.version, packets), rest)
    case 6:
      let (packets, rest) = parseSubPackets(rest)
      return (.lessThan(version: header.version, packets), rest)
    case 7:
      let (packets, rest) = parseSubPackets(rest)
      return (.equalTo(version: header.version, packets), rest)
    default:
      return nil

    }
  }
}

func versions(packet: BitsPacket) -> [Int] {
  switch packet {
  case .literal(let version, _):
    return [Int(version)]
  case .sum(let version, let packets), .product(let version, let packets),
    .minimum(let version, let packets), .maximum(let version, let packets),
    .greaterThan(let version, let packets), .lessThan(let version, let packets),
    .equalTo(let version, let packets):
    return [Int(version)] + packets.flatMap { versions(packet: $0) }
  }
}

func sumVersions(packet: BitsPacket) -> Int {
  return versions(packet: packet).reduce(0, +)
}

func eval(_ packet: BitsPacket) -> Int {
  switch packet {
  case .literal(_, let value): return value
  case .sum(_, let packets): return packets.map { eval($0) }.reduce(0, +)
  case .product(_, let packets): return packets.map { eval($0) }.reduce(1, *)
  case .minimum(_, let packets): return packets.map { eval($0) }.min()!
  case .maximum(_, let packets): return packets.map { eval($0) }.max()!
  case .greaterThan(_, let packets): return eval(packets.first!) > eval(packets.last!) ? 1 : 0
  case .lessThan(_, let packets): return eval(packets.first!) < eval(packets.last!) ? 1 : 0
  case .equalTo(_, let packets): return eval(packets.first!) == eval(packets.last!) ? 1 : 0
  }
}

func bitStream(from: String.SubSequence) -> [UInt8] {
  let chars = from.map { $0 }
  let packet: [String] = chars.map {
    let binary = String($0.hexDigitValue!, radix: 2)
    let prefix = String(repeating: "0", count: 4 - binary.count)
    return prefix + binary
  }

  // print("CharStream:", chars)
  // print("Nibbles", packet.joined())

  let bitStream: [UInt8] = packet.flatMap { $0.map { UInt8($0.wholeNumberValue!) } }

  return bitStream
}

let day16 = problem(day: 16) { input in

  let bitStream = bitStream(from: input.lines.first!)

  part1(example: 23, answer: 996) {
    testMoreExamplesOne()
    testMoreExamplesTwo()
    testMoreExamplesThree()
    testMoreExamplesFour()

    let (packet, _) = BitsPacket.parse(bitStream: bitStream[...])!

    return sumVersions(packet: packet)
  }

  part2(example: 46, answer: 96_257_984_154) {
    let (packet, _) = BitsPacket.parse(bitStream: bitStream[...])!

    return eval(packet)
  }
}

func testLiteral() {
  let stream = bitStream(from: "D2FE28"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(packet == .literal(version: 6, 2021))
}

func testOperatorTypeID_0() {
  let stream = bitStream(from: "38006F45291200"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .lessThan(
        version: 1,
        [
          .literal(version: 6, 10),
          .literal(version: 2, 20),
        ]), "expected \(packet)")
}

func testOperatorTypeID_1() {
  let stream = bitStream(from: "EE00D40C823060"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .maximum(
        version: 7,
        [
          .literal(version: 2, 1),
          .literal(version: 4, 2),
          .literal(version: 1, 3),
        ]), "expected \(packet)")
}

func testMoreExamplesOne() {
  let stream = bitStream(from: "8A004A801A8002F478"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .minimum(
        version: 4,
        [
          .minimum(
            version: 1,
            [
              .minimum(
                version: 5,
                [
                  .literal(version: 6, 15)
                ])
            ])
        ]), "expected \(packet)")

  // Should sum to 16
  assert(sumVersions(packet: packet) == 16)
}

func testMoreExamplesTwo() {
  let stream = bitStream(from: "620080001611562C8802118E34"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .sum(
        version: 3,
        [
          .sum(
            version: 0,
            [
              .literal(version: 0, 10),
              .literal(version: 5, 11),
            ]),
          .sum(
            version: 1,
            [
              .literal(version: 0, 12),
              .literal(version: 3, 13),
            ]),
        ]), "expected \(packet)")

  // Should sum to 12
  assert(sumVersions(packet: packet) == 12)
}

func testMoreExamplesThree() {
  let stream = bitStream(from: "C0015000016115A2E0802F182340"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .sum(
        version: 6,
        [
          .sum(
            version: 0,
            [
              .literal(version: 0, 10),
              .literal(version: 6, 11),
            ]),
          .sum(
            version: 4,
            [
              .literal(version: 7, 12),
              .literal(version: 0, 13),
            ]),

        ]), "expected \(packet)")

  // Should sum to 23
  assert(sumVersions(packet: packet) == 23)
}

func testMoreExamplesFour() {
  let stream = bitStream(from: "A0016C880162017C3686B18A3D4780"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .sum(
        version: 5,
        [
          .sum(
            version: 1,
            [
              .sum(
                version: 3,
                [
                  .literal(version: 7, 6),
                  .literal(version: 6, 6),
                  .literal(version: 5, 12),
                  .literal(version: 2, 15),
                  .literal(version: 2, 15),
                ])
            ])
        ]), "expected \(packet)")

  // Should sum to 31
  assert(sumVersions(packet: packet) == 31)
}
