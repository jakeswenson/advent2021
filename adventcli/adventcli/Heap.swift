
typealias Predicate<T> = (T, T) -> Bool

struct Heap<T> {
    let values: [T?]
    let comparing: Predicate<T>
    let numElements: Int

    var lastElementIndex: Int {
        numElements - 1
    }

    private init(_ values: [T?], comparer: @escaping Predicate<T>, numElements: Int = 0) {
        self.values = values
        self.comparing = comparer
        self.numElements = numElements
    }

    init(comparer: @escaping Predicate<T>) {
        self.init(Array(repeating: nil, count: 1), comparer: comparer)
    }

    private func compare(_ left: T?, _ right: T?) -> Bool {
        if left == nil && right == nil {
            return false
        }
        else if left == nil {
            return false
        } else if right == nil {
            return true
        }

        return comparing(left!, right!)
    }

    private func percolateUp(_ values: [T?], idx: Int) -> [T?] {
        var values = values

        var parent = (idx-1)/2
        var idx = idx

        while(idx != 0 && compare(values[idx], values[parent])) {
            values.swapAt(parent, idx)
            (parent, idx) = ((parent-1)/2, parent)
        }

        return values
    }

    private func percolateDown(_ values: [T?], idx: Int, numElements: Int) -> [T?] {
        var values = values
        var idx = idx
        let lastIdx = numElements-1

        while(idx < lastIdx) {

            let left = idx * 2 + 1
            let right = left + 1
            var best = idx

            if left <= lastIdx && compare(values[left], values[best]) {
                best = left
            }

            if right <= lastIdx && compare(values[right], values[best]) {
                best = right
            }

            if best == idx {
                break;
            }

            values.swapAt(best, idx)
            idx = best
        }

        return values
    }

    func insert(_ value: T) -> Heap<T> {
        var values = values
        let numEls = numElements

        if values.endIndex <= numEls {
            values.append(value)
        } else {
            values[numEls] = value
        }


        return Heap(percolateUp(values, idx: numEls), comparer: comparing, numElements: numEls + 1)
    }

    func removeFirst() -> (T, Heap<T>)? {
        guard numElements > 0 else {
            return nil
        }

        let firstElement = values[0]!

        var values = values

        values[0] = values[lastElementIndex]
        values[lastElementIndex] = nil
        let newNumElements = numElements - 1

        let newHeap = Heap(percolateDown(values, idx: 0, numElements: newNumElements), comparer: comparing, numElements: newNumElements)

        return (firstElement, newHeap)
    }
}

struct PriorityPair<T>: Comparable {
    static func < (lhs: PriorityPair<T>, rhs: PriorityPair<T>) -> Bool {
        lhs.priority < rhs.priority
    }

    static func == (lhs: PriorityPair<T>, rhs: PriorityPair<T>) -> Bool {
        lhs.priority == rhs.priority
    }

    let priority: Int
    let item: T
}

extension Heap where T: Comparable {
    static func minHeap() -> Heap<T> {
        Heap(comparer: <)
    }

    static func maxHeap() -> Heap<T> {
        Heap(comparer: >)
    }
}
