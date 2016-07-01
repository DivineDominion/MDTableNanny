import Foundation

protocol CellDataContainer {

    func cellData(index: Index) -> CellData
}

/// Contents of a cell in the table.
enum CellData {

    case Empty
    case Text(String)

    var content: String {
        switch self {
        case .Empty: return ""
        case let .Text(text): return text
        }
    }

}

extension CellData: CustomDebugStringConvertible {

    var debugDescription: String {

        switch self {
        case .Empty: return "(Empty)"
        case let .Text(text): return "'\(text)\'"
        }
    }
}

extension CellData: Equatable { }

func ==(lhs: CellData, rhs: CellData) -> Bool {

    switch (lhs, rhs) {
    case (.Empty, .Empty): return true
    case let (.Text(lText), .Text(rText)): return lText == rText
    default: return false
    }
}
