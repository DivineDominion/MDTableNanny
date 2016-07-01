import Foundation

enum MarkdownPart {
    case Table(MarkdownTable)
    case Text(Lines)
}

struct MarkdownContents {

    var parts: [MarkdownPart]
    var tableParts: [MarkdownPart] {
        return self.parts.filter {
            if case .Table(_) = $0 { return true }
            return false
        }
    }

    var selectedTable: Int = 0
    var partsCount: Int { return parts.count }

    init(parts: [MarkdownPart]) {

        self.parts = parts
    }

    subscript (part index: Int) -> MarkdownPart {

        return parts[index]
    }

    subscript (table index: Int) -> MarkdownPart {
        get {
            return tableParts[index]
        }
        set {
            replaceTable(index: index, table: newValue)
        }
    }

    private mutating func replaceTable(index index: Int, table: MarkdownPart) {

        guard case .Table(_) = table else { preconditionFailure("expected MarkdownPart.Table") }

        func nthTable(index: Int) -> (element: MarkdownPart) -> Bool {
            var tableCount = 0
            return {
                guard case .Table(_) = $0 else { return false }
                guard tableCount == index else { tableCount += 1; return false }
                return true
            }
        }

        guard let tableIndex = parts.indexOf(nthTable(index)) else { return }

        parts[tableIndex] = table
    }
}

extension MarkdownContents: MultipleTables {

    var tables: [MarkdownTable] {

        return self.tableParts.flatMap {
            if case let .Table(table) = $0 { return table }
            return nil
        }
    }

    mutating func replaceTable(index index: Int, table: MarkdownTable) {

        guard (0...tables.count).contains(index) else { return }

        self[table: index] = .Table(table)
    }

    func rowStream() -> FragmentedMarkdownRowStream {

        return FragmentedMarkdownRowStream(parts: self.parts)
    }
}
