import Foundation

struct Row {

    private var columns: [Index : CellData] = [:]

    var isEmpty: Bool {
        return columns.isEmpty
    }

    var count: Int {
        return columns.count
    }

    init() { }
    
    init(cells: [Index : CellData]) {

        self.columns = cells
    }

    func cell(column column: Index) -> CellData? {

        return columns[column]
    }

    func canShrinkToIndex(index: Index) -> Bool {

        guard let lastRowIndex = columns.keys.sort().last else {
            return true
        }

        return lastRowIndex <= index
    }

    subscript (index: Index) -> CellData? {

        return cell(column: index)
    }
}

extension Row: CellDataContainer {

    func cellData(index: Index) -> CellData {

        return cell(column: index) ?? .Empty
    }
}

extension Row: CustomDebugStringConvertible {

    var debugDescription: String {

        guard !columns.isEmpty
            else { return "(<No Cells>)" }

        return columns
            .map { "(\($0.0.debugDescription) = \($0.1.debugDescription))" }
            .joinWithSeparator(", ")
    }
}

extension Row: Equatable { }

func ==(lhs: Row, rhs: Row) -> Bool {

    return lhs.columns == rhs.columns
}
