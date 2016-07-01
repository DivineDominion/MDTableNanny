import Foundation

extension String {

    func padded(length length: Int, filler: Character = " ") -> String {

        let byteLength = self.lengthOfBytesUsingEncoding(NSUTF32StringEncoding) / 4
        let paddingLength = length - byteLength
        let padding = String(count: paddingLength, repeatedValue: filler)

        return "\(self)\(padding)"
    }
}

private extension Row {

    func cellContent(column column: Index) -> String {
        return cell(column: column)?.content ?? " "
    }
}

class NormalizeMarkdownTable {

    let table: MarkdownTable
    var columnRange: Range<Index> {
        return Index.first...Index(table.tableSize.columns)!
    }

    init(table: MarkdownTable) {

        self.table = table
    }

    lazy var columnWidths: RenderedColumnWidths = RenderedColumnWidths(table: self.table)

    func renderedTable() -> Lines {

        let headerLines = renderedHeader()
        let bodyLines = renderedBody()
        return Array([headerLines, bodyLines].flatten())
    }

    private func renderedHeader() -> [String] {

        guard hasHeader else { return [] }

        let cells = columnRange.map(renderedHeaderCell)
        let headerContents = cells.joinWithSeparator(" | ")
        let headers = table.variant.embeddedInPipes(row: headerContents)

        let separatorsCells = columnRange.map(renderedSeparator)
        let separatorContents = separatorsCells.joinWithSeparator(" | ")
        let separators = table.variant.embeddedInPipes(row: separatorContents)

        return [headers, separators]
    }

    private var hasHeader: Bool {

        guard !table.columnInformation.isEmpty else { return false }

        func isNonEmptyHeading(column: Index, heading: ColumnHeading) -> Bool {

            switch heading {
            case .None: return false
            case let .Text(text): return !text.isEmpty
            }
        }

        let headingContents = table.columnInformation.columnHeadings.filter(isNonEmptyHeading)

        return !headingContents.isEmpty
    }

    private func renderedHeaderCell(column column: Index) -> String {

        let cell = table.escapedColumnHeadingContent(column: column)
        let width = self.columnWidths.columnWidth(index: column) ?? 1
        return cell.padded(length: width)
    }

    private func renderedSeparator(column column: Index) -> String {

        let width = self.columnWidths.columnWidth(index: column) ?? 1
        return String(count: width, repeatedValue: Character("-"))
    }

    private func renderedBody() -> [String] {

        return table.rows.map(renderedRow)
    }

    private func renderedRow(row row: Row) -> String {

        let cells = columnRange.map(renderedCell(row: row))
        let rowContents = cells.joinWithSeparator(" | ")
        return table.variant.embeddedInPipes(row: rowContents)
    }

    private func renderedCell(row row: Row) -> (column: Index) -> String {

        return { column in
            let cell = row.cellContent(column: column)
            let width = self.columnWidths.columnWidth(index: column) ?? 0
            return cell.padded(length: width)
        }
    }
}
