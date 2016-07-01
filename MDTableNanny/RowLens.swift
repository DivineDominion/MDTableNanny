import Foundation

struct RowLens {

    let table: TableRepresentation

    init(table: TableRepresentation) {

        self.table = table
    }
}

extension RowLens: CollectionType {

    subscript (rowIndex: Index) -> Row {

        return table.select(row: rowIndex)
    }

    var startIndex: Index {

        return Index.first
    }

    var endIndex: Index {

        return Index(table.tableSize.rows + 1)!
    }
}
