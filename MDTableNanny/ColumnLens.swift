import Foundation

struct ColumnLens {

    let table: TableRepresentation
}

extension ColumnLens: CollectionType {

    subscript (columnIndex: Index) -> Column {

        precondition(columnIndex < endIndex, "ColumnLens index \(columnIndex) must not exceed supported table limit \(endIndex.predecessor()!)")

        let columnData = table.columnData(columnIndex)
        let columnHeading = table.columnHeading(columnIndex)

        return Column(
            columnData: columnData ?? ColumnData(),
            heading: columnHeading ?? ColumnHeading.None)
    }

    var startIndex: Index {

        return Index.first
    }

    var endIndex: Index {

        return Index(table.tableSize.columns + 1)!
    }
}
