import Foundation

struct TableData {

    var columns: [Index : ColumnData]

    init() {

        self.columns = [ : ]
    }

    func cellData(coordinates: Coordinates) -> CellData? {

        return columns[coordinates.column]?.cellData(row: coordinates.row)
    }

    mutating func insertCell(newCell: NewCell) {

        return insertCell(newCell.coordinates, cellData: newCell.data)
    }

    mutating func insertCell(coordinates: Coordinates, cellData: CellData) {

        let columnIndex = coordinates.column
        var columnData: ColumnData

        if let existingColumn = columns[columnIndex] {
            columnData = existingColumn
        } else {
            columnData = ColumnData()
        }

        columnData.insertCell(coordinates, cellData: cellData)
        columns[columnIndex] = columnData
    }

    func select(rowIndex rowIndex: Index) -> [Index : CellData] {

        return columns.flatMapDictionary { columnIndex, column in

            guard let cell = column.cellData(row: rowIndex) else {
                return nil
            }

            return (columnIndex, cell)
        }
    }
}

extension TableData {

    mutating func replaceColumn(at index: Index, contents: ColumnContents) {

        columns[index] = contents.columnData
    }

    mutating func insertColumn(before index: Index, contents: ColumnContents) {

        let columnsToMove = columns.filter { $0.0 >= index }
            .sort(descending)

        for (columnIndex, columnData) in columnsToMove {

            columns[columnIndex.successor()] = columnData
            columns[columnIndex] = nil
        }

        columns[index] = contents.columnData
    }

    mutating func removeColumn(at index: Index) {

        columns[index] = nil

        let columnsToMove = columns.filter { $0.0 > index }
            .sort(ascending)

        for (columnIndex, column) in columnsToMove {

            columns[columnIndex.predecessor()!] = column
            columns[columnIndex] = nil
        }
    }

    mutating func replaceRow(at index: Index, contents: RowContents) {

        for (columnIndex, columnData) in columns {

            let cell = contents.cell(column: columnIndex)
            var column = columnData
            column.changeCellData(row: index, cellData: cell)

            columns[columnIndex] = column.isEmpty ? nil : column
        }
    }

    mutating func insertRow(before index: Index, contents: RowContents) {

        for (columnIndex, columnData) in columns {

            var column = columnData
            column.insertRow(before: index)

            let cell = contents.cell(column: columnIndex)
            column.changeCellData(row: index, cellData: cell)

            columns[columnIndex] = column
        }
    }

    mutating func removeRow(at index: Index) {

        for (columnIndex, columnData) in columns {

            var column = columnData
            column.removeRow(index: index)

            columns[columnIndex] = column
        }
    }
}

extension TableData {

    init(cells: [Coordinates : CellData]) {

        self.columns = [ : ]

        for (coordinates, cellData) in cells {
            insertCell(coordinates, cellData: cellData)
        }
    }
}

extension TableData: CustomDebugStringConvertible {

    var debugDescription: String {

        return columns.map { columnIndex, column in
            "Col \(columnIndex) = \(column.debugDescription)"
        }.joinWithSeparator(String.newline)
    }
}

extension TableData: Equatable { }

func ==(lhs: TableData, rhs: TableData) -> Bool {

    return lhs.columns == rhs.columns
}
