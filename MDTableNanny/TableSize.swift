import Foundation

struct TableSize {

    private(set) var columns: UInt = 0
    private(set) var rows: UInt = 0

    mutating func increaseColumns() {

        columns += 1
    }

    func increasedColumns() -> TableSize {

        var result = self
        result.increaseColumns()
        return result
    }

    mutating func decreaseColumns() {

        columns -= 1
    }

    mutating func increaseRows() {

        rows += 1
    }

    func increasedRows() -> TableSize {

        var result = self
        result.increaseRows()
        return result
    }

    mutating func decreaseRows() {

        rows -= 1
    }

    func accomodatesCell(cell: NewCell) -> Bool {

        return includes(coordinates: cell.coordinates)
    }

    func includes(coordinates coordinates: Coordinates) -> Bool {

        return includes(column: coordinates.column) && includes(row: coordinates.row)
    }

    func includes(column column: Index) -> Bool {

        return column <= columns
    }

    func includes(row row: Index) -> Bool {

        return row <= rows
    }
}

extension TableSize: CustomDebugStringConvertible {

    var debugDescription: String {
        return "\(columns)x\(rows)"
    }
}

extension TableSize: Equatable { }

func ==(lhs: TableSize, rhs: TableSize) -> Bool {

    return lhs.columns == rhs.columns && lhs.rows == rhs.rows
}
