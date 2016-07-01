import Foundation

struct ColumnData {

    var rows: [Index : CellData]
    var isEmpty: Bool { return rows.isEmpty }

    init() {

        self.rows = [ : ]
    }

    init(rows: [Index : CellData]) {

        self.rows = rows
    }

    func cellData(row index: Index) -> CellData? {

        return rows[index]
    }

    mutating func changeCellData(row index: Index, cellData: CellData?) {

        rows[index] = cellData
    }

    mutating func insertCell(coordinates: Coordinates, cellData: CellData) {

        rows[coordinates.row] = cellData
    }

    mutating func insertRow(before index: Index) {

        let rowsToMove = rows.filter { $0.0 >= index }
            .sort(descending)

        for (row, cellData) in rowsToMove {

            rows[row.successor()] = cellData
            rows[row] = nil
        }
    }

    mutating func removeRow(index index: Index) {

        rows[index] = nil

        let rowsToMove = rows.filter { $0.0 > index }
            .sort(ascending)

        for (row, cellData) in rowsToMove {

            rows[row.predecessor()!] = cellData
            rows[row] = nil
        }
    }
}

extension ColumnData: CustomDebugStringConvertible {

    var debugDescription: String {

        return rows.map { rowIndex, cellData in
            "\(rowIndex):\(cellData)"
        }.joinWithSeparator(", ")
    }
}

extension ColumnData: Equatable { }

func ==(lhs: ColumnData, rhs: ColumnData) -> Bool {

    return lhs.rows == rhs.rows
}
