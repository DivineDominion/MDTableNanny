import Foundation

struct Cell {

    let cellData: CellData

    var content: String {
        return cellData.content
    }

    var selected: Bool = false

    mutating func select() {

        selected = true
    }

    mutating func deselect() {

        selected = false
    }
}

extension Cell: CustomDebugStringConvertible {

    var debugDescription: String {

        let highlighted = self.selected ? "✓" : ""

        return [
            cellData.debugDescription,
            highlighted
            ].joinWithSeparator("")
    }
}

extension Cell: Equatable { }

func ==(lhs: Cell, rhs: Cell) -> Bool {

    return lhs.cellData == rhs.cellData && lhs.selected == rhs.selected
}
