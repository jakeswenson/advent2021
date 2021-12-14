import Parsing

struct AdventParsers {
  static let line = Parsing.Prefix { (byte: UTF8.CodeUnit) in
    byte != .init(ascii: "\n")
  }

  static let char = First().map { String(Character(UnicodeScalar($0))) }
}
