import Algorithms
import Collections
import CoreFoundation
import Parsing

struct BitStream: Sequence {
  private let inner: ArraySlice<UInt8>

  init(_ inner: ArraySlice<UInt8>) {
    self.inner = inner
  }

  var isEmpty: Bool { inner.isEmpty }

  subscript(_ range: Range<Int>) -> (slice: BitStream, rest: BitStream) {
    let start = range.startIndex + inner.startIndex
    let end = range.endIndex + inner.startIndex
    let slice = BitStream(inner[start..<end])
    let rest = BitStream(inner[end...])
    return (slice: slice, rest: rest)
  }

  subscript(_ range: PartialRangeUpTo<Int>) -> (slice: BitStream, rest: BitStream) {
    let end = range.upperBound + inner.startIndex
    let slice = BitStream(inner[..<end])
    let rest = BitStream(inner[end...])

    return (slice: slice, rest: rest)
  }

  subscript(_ range: PartialRangeFrom<Int>) -> BitStream {
    let start = range.lowerBound + inner.startIndex

    return BitStream(inner[start...])
  }

  subscript(_ range: UnboundedRange) -> BitStream { self }

  subscript(_ idx: Int) -> UInt8 {
    return inner[inner.startIndex + idx]
  }

  func readUInt8() -> UInt8 {
    return self.reduce(UInt8.zero) { n, bit in n << 1 | bit }
  }

  func readUInt8(bits: Int) -> (UInt8, rest: BitStream) {
    assert(bits <= 8)
    let (bits, rest) = self[..<bits]
    return (bits.reduce(UInt8.zero) { n, bit in n << 1 | bit }, rest: rest)
  }

  func readInt(bits: Int) -> (Int, rest: BitStream) {
    let (bits, rest) = self[..<bits]
    return (bits.reduce(Int.zero) { n, bit in n << 1 | Int(bit) }, rest: rest)
  }

  func readVarInt() -> (Int, BitStream) {
    var stream = self
    var int = Int.zero

    while let (chunk, rest) = .some(stream[..<5]) {
      stream = rest

      // print("Chunk", chunk, "start", chunk.startIndex, "end", chunk.endIndex)
      assert(!chunk.isEmpty)
      let intBits = chunk[1...]
      int = intBits.reduce(int) { n, bit in n << 1 | Int(bit) }

      if chunk[0] == 0 {
        break
      }
    }

    return (int, stream)
  }

  func makeIterator() -> ArraySlice<UInt8>.Iterator {
    return inner.makeIterator()
  }
}

struct Header {
  let version: UInt8, type: UInt8

  static func parse(_ stream: BitStream) -> (Header, BitStream) {
    let (version, rest) = stream.readUInt8(bits: 3)
    let (type, body) = rest.readUInt8(bits: 3)
    // print("Version", versionBits, version)
    // print("Type:", typeBits, type)

    return (Header(version: version, type: type), body)
  }
}

func parseMapSubPackets(_ rest: BitStream, builder: ([BitsPacket]) -> BitsPacket) -> (
  BitsPacket, BitStream
) {
  let (type, packets) = rest.readUInt8(bits: 1)

  if type == 0 {
    let (subPacketsSize, rest) = packets.readInt(bits: 15)

    var (subPackets, nextPacket) = rest[..<subPacketsSize]
    var packets: [BitsPacket] = []

    while !subPackets.isEmpty {
      let (packet, rest) = BitsPacket.parse(bitStream: subPackets)!
      packets.append(packet)
      subPackets = rest
    }

    return (builder(packets), nextPacket)
  } else {
    let (numSubPackets, subPackets) = packets.readInt(bits: 11)

    let (packets, rest) = (0..<numSubPackets).reduce(([BitsPacket](), subPackets)) { state, _ in
      var (packets, subPackets) = state
      let (packet, rest) = BitsPacket.parse(bitStream: subPackets)!
      packets.append(packet)
      return (packets, rest)
    }

    return (builder(packets), rest)
  }
}

enum BitsPacket: Equatable, CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .literal(let v, let value): return ".literal(v:\(v), \(value))"
    case .sum(let v, let packets): return ".sum(v:\(v), [\(packets)])"
    case .product(let v, let packets): return ".product(v:\(v), \(packets))"
    case .minimum(let v, let packets): return ".minimum(v:\(v), \(packets))"
    case .maximum(let v, let packets): return ".maximum(v:\(v), \(packets))"
    case .greaterThan(let v, let packets): return ".greaterThan(v:\(v), \(packets))"
    case .lessThan(let v, let packets): return ".lessThan(v:\(v), \(packets))"
    case .equalTo(let v, let packets): return ".equalTo(v:\(v), \(packets))"
    }
  }

  case literal(_ version: UInt8, _ value: Int)
  case sum(_ version: UInt8, packets: [BitsPacket])
  case product(_ version: UInt8, packets: [BitsPacket])
  case minimum(_ version: UInt8, packets: [BitsPacket])
  case maximum(_ version: UInt8, packets: [BitsPacket])
  case greaterThan(_ version: UInt8, packets: [BitsPacket])
  case lessThan(_ version: UInt8, packets: [BitsPacket])
  case equalTo(_ version: UInt8, packets: [BitsPacket])

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

    let (header, rest) = Header.parse(bitStream)

    switch header.type {
    case 4:
      let (value, rest) = rest.readVarInt()
      return (.literal(header.version, value), rest)
    case 0: return parseMapSubPackets(rest) { .sum(header.version, packets: $0) }
    case 1: return parseMapSubPackets(rest) { .product(header.version, packets: $0) }
    case 2: return parseMapSubPackets(rest) { .minimum(header.version, packets: $0) }
    case 3: return parseMapSubPackets(rest) { .maximum(header.version, packets: $0) }
    case 5: return parseMapSubPackets(rest) { .greaterThan(header.version, packets: $0) }
    case 6: return parseMapSubPackets(rest) { .lessThan(header.version, packets: $0) }
    case 7: return parseMapSubPackets(rest) { .equalTo(header.version, packets: $0) }
    default: return nil
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

func bitStream(from: String.SubSequence) -> BitStream {
  let chars = from.map { $0 }
  let packet: [String] = chars.map {
    let binary = String($0.hexDigitValue!, radix: 2)
    let prefix = String(repeating: "0", count: 4 - binary.count)
    return prefix + binary
  }

  // print("CharStream:", chars)
  // print("Nibbles", packet.joined())

  let bitStream: [UInt8] = packet.flatMap { $0.map { UInt8($0.wholeNumberValue!) } }

  return BitStream(bitStream[...])
}

let day16 = problem(day: 16) { input in

  let bitStream = bitStream(from: input.lines.first!)

  part1(example: 23, answer: 996) {
    testMoreExamplesOne()
    testMoreExamplesTwo()
    testMoreExamplesThree()
    testMoreExamplesFour()

    let (packet, _) = BitsPacket.parse(bitStream: bitStream)!

    return sumVersions(packet: packet)
  }

  part2(example: 46, answer: 96_257_984_154) {
    let (packet, _) = BitsPacket.parse(bitStream: bitStream)!

    return eval(packet)
  }
}

func testLiteral() {
  let stream = bitStream(from: "D2FE28"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(packet == .literal(6, 2021))
}

func testOperatorTypeID_0() {
  let stream = bitStream(from: "38006F45291200"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .lessThan(
        1,
        packets: [
          .literal(6, 10),
          .literal(2, 20),
        ]), "expected \(packet)")
}

func testOperatorTypeID_1() {
  let stream = bitStream(from: "EE00D40C823060"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .maximum(
        7,
        packets: [
          .literal(2, 1),
          .literal(4, 2),
          .literal(1, 3),
        ]), "expected \(packet)")
}

func testMoreExamplesOne() {
  let stream = bitStream(from: "8A004A801A8002F478"[...])

  let (packet, _) = BitsPacket.parse(bitStream: stream[...])!

  assert(
    packet
      == .minimum(
        4,
        packets: [
          .minimum(
            1,
            packets: [
              .minimum(
                5,
                packets: [
                  .literal(6, 15)
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
        3,
        packets: [
          .sum(
            0,
            packets: [
              .literal(0, 10),
              .literal(5, 11),
            ]),
          .sum(
            1,
            packets: [
              .literal(0, 12),
              .literal(3, 13),
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
        6,
        packets: [
          .sum(
            0,
            packets: [
              .literal(0, 10),
              .literal(6, 11),
            ]),
          .sum(
            4,
            packets: [
              .literal(7, 12),
              .literal(0, 13),
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
        5,
        packets: [
          .sum(
            1,
            packets: [
              .sum(
                3,
                packets: [
                  .literal(7, 6),
                  .literal(6, 6),
                  .literal(5, 12),
                  .literal(2, 15),
                  .literal(2, 15),
                ])
            ])
        ]), "expected \(packet)")

  // Should sum to 31
  assert(sumVersions(packet: packet) == 31)
}
