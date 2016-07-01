import Foundation

/// Positive, non-zero integer index.
struct Index {

    static let first = Index(1)!
    
    let value: UInt
    var arrayIndex: Int {
        return Int(value) - 1
    }
    
    init?(arrayIndex fromInt: Int) {

        guard fromInt >= 0 else { return nil }

        value = UInt(fromInt + 1)
    }

    init?(_ fromInt: Int) {

        guard fromInt > 0 else { return nil }

        value = UInt(fromInt)
    }

    init?(_ fromUInt: UInt) {

        guard fromUInt > 0 else { return nil }

        value = fromUInt
    }
}

func descending(lhs: (Index, Any), _ rhs: (Index, Any)) -> Bool {

    return lhs.0 > rhs.0
}

func ascending(lhs: (Index, Any), _ rhs: (Index, Any)) -> Bool {

    return lhs.0 < rhs.0
}

extension Index: ForwardIndexType {

    func distanceTo(end: Index) -> UInt {

        let distance: Int = distanceTo(end)

        return UInt(abs(distance))
    }
    
    func successor() -> Index {

        return Index(value + 1)!
    }

    func predecessor() -> Index? {

        return Index(value - 1)
    }
}

extension Index: CustomDebugStringConvertible {

    var debugDescription: String {
        return "#\(value)"
    }
}

extension Index: Hashable {

    var hashValue: Int { return 42 &* value.hashValue }
}

// MARK: Equality

extension Index: Equatable { }

func ==(lhs: Index, rhs: Index) -> Bool {

    return lhs.value == rhs.value
}

func ==(lhs: Index, rhs: UInt) -> Bool {

    return lhs.value == rhs
}

func ==(lhs: UInt, rhs: Index) -> Bool {

    return lhs == rhs.value
}

// MARK: Comparison

extension Index: Comparable { }

func <(lhs: Index, rhs: Index) -> Bool {

    return lhs.value < rhs.value
}

func <(lhs: Index, rhs: UInt) -> Bool {

    return lhs.value < rhs
}

func <=(lhs: Index, rhs: UInt) -> Bool {

    return lhs.value <= rhs
}

func <(lhs: UInt, rhs: Index) -> Bool {

    return lhs < rhs.value
}

func <=(lhs: UInt, rhs: Index) -> Bool {

    return lhs <= rhs.value
}

func >(lhs: Index, rhs: UInt) -> Bool {

    return lhs.value > rhs
}

func >=(lhs: Index, rhs: UInt) -> Bool {

    return lhs.value >= rhs
}

func >(lhs: UInt, rhs: Index) -> Bool {

    return lhs > rhs.value
}

func >=(lhs: UInt, rhs: Index) -> Bool {

    return lhs >= rhs.value
}
