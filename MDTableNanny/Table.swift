import Foundation

struct Table {

    private(set) var tableData: TableData
    private(set) var tableSize: TableSize
    private(set) var columnInformation: ColumnInformation

    init(tableSize: TableSize = TableSize(), cells: [Coordinates : CellData] = [:], columnHeadings: [Index : ColumnHeading] = [:]) {

        self.tableData = TableData(cells: cells)
        self.tableSize = tableSize
        self.columnInformation = ColumnInformation(columnHeadings: columnHeadings)
    }

    mutating func prepareColumn(columnIndex index: Index, heading: ColumnHeading) {

        columnInformation[index] = heading
    }
}

extension Table: MutableTableRepresentation {

    mutating func insert(cell newCell: NewCell) {

        guard tableSize.accomodatesCell(newCell)
            else { return }

        tableData.insertCell(newCell)
    }
}

extension Table: Equatable { }

func ==(lhs: Table, rhs: Table) -> Bool {

    return lhs.tableSize == rhs.tableSize && lhs.tableData == rhs.tableData && lhs.columnInformation == rhs.columnInformation
}
