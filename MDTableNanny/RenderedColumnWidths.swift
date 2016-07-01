import Foundation

struct RenderedColumnWidths {

    let columnWidths: [Int]

    init(table: EscapedTableRepresentation) {

        /// - returns: values >=1 (so that at least one separator hyphen is rendered)
        func columnWidth(index index: Index) -> Int {

            func byLength(lhs: String, rhs: String) -> Bool {
                return lhs.characters.count > rhs.characters.count
            }

            let heading = table.escapedColumnHeadingContent(column: index)
            let cellContents = table.rows
                .map { $0.cell(column: index)?.content ?? " " }
            let cellsSortedByLength = cellContents.appended(heading)
                .sort(byLength)

            guard let longestCell = cellsSortedByLength.first, length = Optional(longestCell.characters.count)
                where length > 0
                else { return 1 }

            return length
        }

        let columnRange: Range<Index> = {

            let columns = table.tableSize.columns
            return Index.first...Index(columns)!
        }()

        self.columnWidths = columnRange.map(columnWidth)
    }

    func columnWidth(index index: Index) -> Int? {

        return columnWidths[safe: index.arrayIndex]
    }
}

extension RenderedColumnWidths: SequenceType {

    func generate() -> AnyGenerator<Int> {
        
        return AnyGenerator(columnWidths.generate())
    }
}
