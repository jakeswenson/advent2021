struct Pair<T, U> {
  let fst: T, snd: U

  init(_ fst: T, _ snd: U) {
    self.fst = fst
    self.snd = snd
  }
}

extension Pair: Hashable, Equatable
where
  T: Hashable & Equatable,
  U: Hashable & Equatable
{
}

extension Sequence where Element: Hashable {
  func elementCounts() -> [Self.Element: Int] {
    self.reduce([Element: Int]()) { counts, element in
      counts.merging([element: 1], uniquingKeysWith: +)
    }

  }
}
