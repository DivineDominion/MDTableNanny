import Foundation

enum ColumnHeading {

    case None
    case Text(String)

    var content: String {
        switch self {
        case .None: return ""
        case let .Text(text): return text
        }
    }
}

extension ColumnHeading: Equatable { }

func ==(lhs: ColumnHeading, rhs: ColumnHeading) -> Bool {

    switch (lhs, rhs) {
    case (.None, .None): return true
    case let (.Text(lText), .Text(rText)): return lText == rText
    default: return false
    }
}

struct Column {

    let heading: ColumnHeading
    private(set) var columnData: ColumnData

    init(columnData: ColumnData, heading: ColumnHeading = .None) {

        self.columnData = columnData
        self.heading = heading
    }

    func canShrinkToIndex(index: Index) -> Bool {

        guard let lastRowIndex = columnData.rows.keys.sort().last else {
            return true
        }

        return lastRowIndex <= index
    }

    func cell(row row: Index) -> CellData? {

        return columnData.cellData(row: row)
    }

    subscript (index: Index) -> CellData? {

        return cell(row: index)
    }
}

extension Column: CellDataContainer {

    func cellData(index: Index) -> CellData {

        return cell(row: index) ?? .Empty
    }
}

extension Column {

    init(cells: [Index : CellData] = [:], heading: ColumnHeading = .None) {

        self.columnData = ColumnData(rows: cells)
        self.heading = heading
    }
}

extension Column: Equatable { }

func ==(lhs: Column, rhs: Column) -> Bool {

    return lhs.heading == rhs.heading && lhs.columnData == rhs.columnData
}

extension Column: CustomDebugStringConvertible {

    var debugDescription: String {

        return "'\(heading)' := \(columnData.rows)"
    }
}
