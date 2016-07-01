import Foundation

enum RowContents {

    case Empty
    case Filled(Row)

    func cell(column index: Index) -> CellData? {

        switch self {
        case .Empty: return nil
        case let .Filled(row): return row.cell(column: index)
        }
    }
}

extension RowContents: Equatable { }

func ==(lhs: RowContents, rhs: RowContents) -> Bool {

    switch (lhs, rhs) {
    case (.Empty, .Empty): return true
    case let (.Filled(lRow), .Filled(rRow)): return lRow == rRow
    default: return false
    }
}
