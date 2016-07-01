import Foundation

/// Representation of 2-dimensional data, optimized for access by columns.
protocol TableRepresentation: DefaultReflectable, CustomDebugStringConvertible {

    // MARK: Table contents

    var tableSize: TableSize { get }
    var tableData: TableData { get }

    var rows: RowLens { get }
    var columns: ColumnLens { get }

    func cellData(coordinates: Coordinates) -> CellData?

    /// Returns a cross section of data from all columns at the given row.
    func select(row rowIndex: Index) -> Row

    /// - returns: `nil` when out of bounds
    func columnData(index: Index) -> ColumnData?

    
    // MARK: Table metadata

    var columnInformation: ColumnInformation { get }

    /// - returns: `nil` when out of bounds
    func columnHeading(index: Index) -> ColumnHeading?
}

func ==(lhs: TableRepresentation, rhs: TableRepresentation) -> Bool {

    return lhs.tableSize == rhs.tableSize && lhs.tableData == rhs.tableData && lhs.columnInformation == rhs.columnInformation
}

extension TableRepresentation {

    func columnData(index: Index) -> ColumnData? {

        return tableData.columns[index]
    }
    
    func columnHeading(index: Index) -> ColumnHeading? {

        return columnInformation[index]
    }

    func cellData(coordinates: Coordinates) -> CellData? {

        return tableData.cellData(coordinates)
    }

    func select(row rowIndex: Index) -> Row {

        let cells = tableData.select(rowIndex: rowIndex)

        return Row(cells: cells)
    }

    var rows: RowLens {

        return RowLens(table: self)
    }

    var columns: ColumnLens {

        return ColumnLens(table: self)
    }
}

extension TableRepresentation {

    var debugDescription: String {
        let heading = "\(tableSize.debugDescription) table\n"

        let cols = columns.indexedElements().map { index, column in
            "Col \(index) is \(column.debugDescription)"
            }.joinWithSeparator(String.newline)

        return "\(heading)\(cols)"
    }
}
