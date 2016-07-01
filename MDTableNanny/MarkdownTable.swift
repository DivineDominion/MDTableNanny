import Foundation

struct MarkdownTable: TableRepresentation {

    private(set) var variant: MarkdownTableVariant
    private(set) var tableData: TableData
    private(set) var tableSize: TableSize
    private(set) var columnInformation: ColumnInformation

    init(tableSize: TableSize = TableSize(),
         cells: [Coordinates : CellData] = [:],
         columnHeadings: [Index : ColumnHeading] = [:],
         variant: MarkdownTableVariant = .Unknown) {

        self.tableData = TableData(cells: cells)
        self.tableSize = tableSize
        self.columnInformation = ColumnInformation(columnHeadings: columnHeadings)
        self.variant = variant
    }

    mutating func prepareColumn(columnIndex index: Index, heading: ColumnHeading) {

        columnInformation[index] = heading
    }
}

extension MarkdownTable: MutableTableRepresentation {

    mutating func insert(cell newCell: NewCell) {

        guard tableSize.accomodatesCell(newCell)
            else { return }

        tableData.insertCell(newCell)
    }
}

extension MarkdownTable: Equatable { }

func ==(lhs: MarkdownTable, rhs: MarkdownTable) -> Bool {

    return lhs.tableSize == rhs.tableSize && lhs.tableData == rhs.tableData && lhs.columnInformation == rhs.columnInformation && lhs.variant == rhs.variant
}
