import Foundation

@available(*, deprecated=1.0)
typealias TableState = MutableTableRepresentation

protocol MultipleTables {

    var tables: [TableState] { get }
    var containsTable: Bool { get }
    var selectedTable: Int { get set }
    @available(*, deprecated=1.0)
    var currentTableState: TableState { get }

    mutating func replaceTable(index index: Int, table: TableState)
    mutating func selectTable(index index: Int)

    func rowStream() -> FragmentedMarkdownRowStream
}

extension MultipleTables {

    var containsTable: Bool { return !tables.isEmpty }
    var currentTableState: TableState { return tables[selectedTable] }

    mutating func selectTable(index index: Int) {

        guard (0...tables.count).contains(index) else { return }

        selectedTable = index
    }
}
