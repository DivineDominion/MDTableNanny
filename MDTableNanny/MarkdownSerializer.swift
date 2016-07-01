import Foundation

extension TableRepresentation where Self: TableState {

    var markdownTable: MarkdownTable {

        guard let markdownSelf = self as? MarkdownTable
            else { return MarkdownTable(variant: .Unknown, tableContents: self) }
        return markdownSelf
    }
}

class MarkdownSerializer {

    init() { }
    
    func data(tables tables: MultipleTables) -> NSData? {

        let text = self.string(tables: tables)
        return text.dataUsingEncoding(NSUTF8StringEncoding)
    }

    func string(tables tables: MultipleTables) -> String {

        let content = self.content(tables: tables)
        return content.joinWithSeparator(String.newline)
    }

    func content(tables tables: MultipleTables) -> [String] {

        return Array(tables.rowStream())
    }

    @available(*, deprecated=1.0)
    func content(table table: TableState) -> [String] {

        let markdownTable = table.markdownTable
        let normalizer = NormalizeMarkdownTable(table: markdownTable)
        return normalizer.renderedTable()
    }
}
