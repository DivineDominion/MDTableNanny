import Foundation

struct MarkdownTable {

    private(set) var variant: MarkdownTableVariant
    private(set) var table: TableState

    init(variant: MarkdownTableVariant, tableContents table: TableState = Table()) {

        self.variant = variant
        self.table = table
    }
}

extension MarkdownTable: TableRepresentation {

    var tableSize: TableSize { return table.tableSize }
    var tableData: TableData { return table.tableData }
    var columnInformation: ColumnInformation { return table.columnInformation }
}

extension MarkdownTable: MutableTableRepresentation {

    mutating func insert(cell newCell: NewCell) {

        table.insert(cell: newCell)
    }
}
