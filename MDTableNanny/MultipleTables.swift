import Foundation

@available(*, deprecated=1.0)
typealias TableState = MutableTableRepresentation

protocol MultipleTables {

    var tables: [TableState] { get }
    var containsTable: Bool { get }

    mutating func replaceTable(index index: Int, table: TableState)

    func rowStream() -> FragmentedMarkdownRowStream
}

extension MultipleTables {

    var containsTable: Bool { return !tables.isEmpty }
}
