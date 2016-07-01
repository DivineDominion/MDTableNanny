import Foundation

struct Direction {

    enum Offset: Int {
        case More = 1
        case Same = 0
        case Less = -1
    }

    static let Up    = Direction( 0, -1)!
    static let Down  = Direction( 0,  1)!
    static let Left  = Direction(-1,  0)!
    static let Right = Direction( 1,  0)!

    let offsetX: Offset
    let offsetY: Offset

    var inverse: Direction? {

        switch self {
        case Direction.Up: return Direction.Down
        case Direction.Down: return Direction.Up
        case Direction.Right: return Direction.Left
        case Direction.Left: return Direction.Right
        default: return nil
        }
    }

    private init?(_ offsetX: Int, _ offsetY: Int) {

        guard let offsetX = Offset.init(rawValue: offsetX),
            offsetY = Offset.init(rawValue: offsetY)
            else { return nil }

        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}

extension Direction: Equatable { }

func ==(lhs: Direction, rhs: Direction) -> Bool {

    return lhs.offsetX == rhs.offsetX && lhs.offsetY == rhs.offsetY
}

extension Index {

    func move(direction: Direction.Offset) -> Index? {

        switch direction {
        case .Same: return self
        case .More: return self.successor()
        case .Less: return self.predecessor()
        }
    }
}

extension Coordinates {

    /// - returns: `nil` if moving fails (only when decreasing to index <1), `self` if the result exceeds the optional constraints, or new coordinates if moving succeeds and fits constraints.
    func move(direction: Direction, constrainedBy tableSize: TableSize? = nil) -> Coordinates? {

        guard let movedColumn = column.move(direction.offsetX),
            movedRow = row.move(direction.offsetY)
            else { return nil }

        let result = Coordinates(column: movedColumn, row: movedRow)

        if let tableSize = tableSize
            where !tableSize.includes(coordinates: result) {
                return self
        }

        return result
    }
}
