import Foundation

struct Coordinates {

    let column: Index
    let row: Index

    init(column: Index, row: Index) {

        self.column = column
        self.row = row
    }

    init?(column: UInt, row: UInt) {

        guard let columnIndex = Index(column), rowIndex = Index(row) else {

            return nil
        }

        self.column = columnIndex
        self.row = rowIndex
    }

    init?(columnArrayIndex columnIndex: Int, rowArrayIndex rowIndex: Int) {

        guard let column = Index(columnIndex + 1), row = Index(rowIndex + 1) else {
            return nil
        }

        self.column = column
        self.row = row
    }

}

extension Coordinates: CustomStringConvertible {
    var description: String {
        return "(\(column), \(row))"
    }
}


// MARK: Equatable

extension Coordinates: Equatable { }

func ==(lhs: Coordinates, rhs: Coordinates) -> Bool {

    return lhs.column == rhs.column && lhs.row == rhs.row
}

extension Coordinates: Hashable {

    var hashValue: Int {
        let x = column.hashValue
        let y = row.hashValue
        return  ((x + y) &* (x + y + 1) / 2) + y
    }
}
