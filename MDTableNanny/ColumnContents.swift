import Foundation

enum ColumnContents {

    case Empty
    case Filled(Column)

    var columnData: ColumnData? {

        switch self {
        case .Empty: return nil
        case let .Filled(column): return column.columnData
        }
    }

    var columnHeading: ColumnHeading? {

        switch self {
        case .Empty: return nil
        case let .Filled(column): return column.heading
        }
    }
}

extension ColumnContents: Equatable { }

func ==(lhs: ColumnContents, rhs: ColumnContents) -> Bool {

    switch (lhs, rhs) {
    case (.Empty, .Empty): return true
    case let (.Filled(lColumn), .Filled(rColumn)): return lColumn == rColumn
    default: return false
    }
}
