import Foundation

protocol MultipleTables {

    var tables: [MarkdownTable] { get }
    var containsTable: Bool { get }

    mutating func replaceTable(index index: Int, table: MarkdownTable)

    func rowStream() -> FragmentedMarkdownRowStream
}

extension MultipleTables {

    var containsTable: Bool { return !tables.isEmpty }
}
