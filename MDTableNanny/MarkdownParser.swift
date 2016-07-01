import Foundation

class MarkdownParser {

    let tableContentsFactory: MarkdownTableContentsFactory

    init(tableContentsFactory: MarkdownTableContentsFactory = MarkdownTableContentsFactory()) {

        self.tableContentsFactory = tableContentsFactory
    }

    func parse(tokens tokens: [MarkdownTokenizer.Token], tableFactory: TableFactory) throws -> MarkdownContents {

        let parts: [MarkdownPart] = try tokens.map { token in

            switch token {
            case let .Text(lines):
                return MarkdownPart.Text(lines)
            case let .Table(lines, hasHeader: hasHeader):
                let table = try self.markdownTable(lines: lines, includeHeader: hasHeader, tableFactory: tableFactory)
                return MarkdownPart.Table(table)
            }
        }

        return MarkdownContents(parts: parts)
    }

    private func markdownTable(lines lines: Lines, includeHeader: Bool, tableFactory: TableFactory) throws -> MarkdownTable {

        let tableContents = self.tableContentsFactory.build(lines: lines, hasHeaders: includeHeader)
        let variant = tableContents.variant
        let table = try tableFactory.table(data: tableContents.columnData, variant: variant)
        
        return table
    }
}
