import Foundation

enum ImportError: ErrorType {

    case OpeningMDFailed(NSURL, ErrorType)
    case CannotPrepareStream

    case OpeningCSVFailed(NSURL, ErrorType)
    case InconsistentInternalData
    case UnsupportedCellType(column: Int, row: Int)
}

class CellFactory {

    func newCell(object: AnyObject, column: Index, row: Index) throws -> NewCell {

        let coordinates = Coordinates(column: column, row: row)
        
        switch object {
        case let text as String:
            return NewCell(coordinates: coordinates, data: CellData.Text(text))
        default:
            throw ImportError.UnsupportedCellType(column: Int(column.value), row: Int(row.value))
        }
    }
}

class TableFactory {

    struct ColumnData {

        let heading: ColumnHeading
        let rows: [String?]
    }

    let cellFactory: CellFactory

    init(cellFactory: CellFactory = CellFactory()) {

        self.cellFactory = cellFactory
    }

    func table(data columns: [ColumnData], variant: MarkdownTableVariant = .Unknown) throws -> MarkdownTable {

        let columnCount = columns.count
        let largestRowCount = columns.map { $0.rows.count }.sort().last ?? 0

        let size = TableSize(columns: UInt(columnCount), rows: UInt(largestRowCount))

        var table = MarkdownTable(tableSize: size, cells: [:], variant: variant)

        for (columnIndex, columnData) in columns.indexedElements() {

            table.prepareColumn(columnIndex: columnIndex, heading: columnData.heading)

            for case let (rowIndex, .Some(cellContent)) in columnData.rows.indexedElements() {

                let cell = try cellFactory.newCell(cellContent, column: columnIndex, row: rowIndex)
                table.insert(cell: cell)
            }
        }

        return table
    }
}

extension TableFactory.ColumnData: Equatable { }

func ==(lhs: TableFactory.ColumnData, rhs: TableFactory.ColumnData) -> Bool {

    func rowsEqual(lhs: [String?], _ rhs: [String?]) -> Bool {

        guard lhs.count == rhs.count else { return false }

        for (l, r) in zip(lhs, rhs) {
            guard l == r else { return false }
        }

        return true
    }

    return lhs.heading == rhs.heading && rowsEqual(lhs.rows, rhs.rows)
}
