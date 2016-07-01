import Foundation

extension MarkdownTableVariant {

    private func cellsFromRow(row: String) -> [String?] {

        guard let rowComponents = self.components(row) else {
            return []
        }

        return rowComponents.cellsFromBody.map(nillifyEmptyString)
    }
}

private func nillifyEmptyString(cell: String) -> String? {

    return cell.isEmpty ? nil : cell
}

struct MarkdownTableContents {

    let tableSize: TableSize
    let variant: MarkdownTableVariant
    let columnHeadings: [ColumnHeading]
    let columnData: [TableFactory.ColumnData]
}

class MarkdownTableContentsFactory {

    init() { }

    func build(lines tableLines: Lines, hasHeaders: Bool) -> MarkdownTableContents {

        // Trim frist line so that leading whitespace doesn't
        // change the resulting size and variant.
        guard let firstLine = tableLines.first?.stringByTrimmingWhitespace() else {
            
            return MarkdownTableContents(tableSize: TableSize(), variant: .Unknown, columnHeadings: [], columnData: [])
        }

        let variant = recognizeVariant(line: firstLine)
        let contentLines = hasHeaders ? Array(tableLines.dropFirst()) : tableLines

        let tableSize = determineTableSize(variant: variant, firstLine: firstLine, contentLines: contentLines)

        let columnHeadings: [ColumnHeading] = {

            guard hasHeaders
                else { return tableSize.columns.times { ColumnHeading.None } }

            return extractColumnHeadings(headingsLine: firstLine, variant: variant)
        }()

        let columnData = extractColumns(contentLines: contentLines, variant: variant, columnHeadings: columnHeadings)

        return MarkdownTableContents(tableSize: tableSize,
                                     variant: variant,
                                     columnHeadings: columnHeadings,
                                     columnData: columnData)
    }

    private func recognizeVariant(line line: String) -> MarkdownTableVariant {

        return MarkdownTableVariant.recognizeVariant(line)
    }

    private func determineTableSize(variant variant: MarkdownTableVariant, firstLine aLine: String, contentLines: Lines) -> TableSize {

        let pipeCount = aLine
            .characters.filter { $0 == Character("|") }
            .count
        let columnSeparatorCount = pipeCount - variant.surroundingPipeCount
        let columnCount = columnSeparatorCount + 1

        return TableSize(
            columns: UInt(columnCount),
            rows: UInt(contentLines.count))
    }

    private func extractColumnHeadings(headingsLine headingsLine: String, variant: MarkdownTableVariant) -> [ColumnHeading] {

        let cells = variant.cellsFromRow(headingsLine)

        return cells.map { heading in

            guard let text = heading else { return .None }
            return .Text(text)
        }
    }

    private func extractColumns(contentLines contentLines: Lines, variant: MarkdownTableVariant, columnHeadings: [ColumnHeading]) -> [TableFactory.ColumnData] {

        let rows = contentLines.map(variant.cellsFromRow)

        let data: [TableFactory.ColumnData] = columnHeadings.enumerate().map { index, heading in

            let rowsInCol = rows.flatMap { $0[safe: UInt(index)] }

            return TableFactory.ColumnData(heading: heading, rows: rowsInCol)
        }

        return data
    }
}
