import XCTest
@testable import MDTableNanny

class NormalizeMarkdownTableTests: XCTestCase {

    func testNormalization_EmptyCells() {

        let table = createTable(
            cells: [["", "", ""]],
            headings: [])
        let markdownTable = MarkdownTable(variant: .SurroundingPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "|   |   |   |",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_EscapingPipes() {

        let table = createTable(
            cells: [["AA", "B | b", "CCC"]],
            headings: [.Text("1"), .Text("2|2"), .Text("3")])
        let markdownTable = MarkdownTable(variant: .SurroundingPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "| 1  | 2\\|2   | 3   |",
            "| -- | ------ | --- |",
            "| AA | B \\| b | CCC |",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_GapColumn() {

        let table = createTable(
            cells: [["AA", "", "C"]],
            headings: [.Text("1"), .None, .Text("3")])
        let markdownTable = MarkdownTable(variant: .SurroundingPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "| 1  |   | 3 |",
            "| -- | - | - |",
            "| AA |   | C |",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_NoPipes() {

        let table = createTable(
            cells: [["AA", "B", "CCC"]],
            headings: [.Text("1"), .Text("2222"), .Text("3")])
        let markdownTable = MarkdownTable(variant: .NoPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "1  | 2222 | 3  ",
            "-- | ---- | ---",
            "AA | B    | CCC",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_NoPipes_WithoutHeader() {

        let table = createTable(
            cells: [["AA", "BB", "CCC"], ["DDDD", "E", "FF"]],
            headings: [])
        let markdownTable = MarkdownTable(variant: .NoPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "AA   | BB | CCC",
            "DDDD | E  | FF ",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_NoPipes_WithHeadersSetToNone() {

        let table = createTable(
            cells: [["AA", "BB", "CCC"], ["DDDD", "E", "FF"]],
            headings: [.None, .None])
        let markdownTable = MarkdownTable(variant: .NoPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "AA   | BB | CCC",
            "DDDD | E  | FF ",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_TrailingPipes() {

        let table = createTable(
            cells: [["short", "long cell", "very long cell"]],
            headings: [.Text("The first"), .Text("2nd"), .Text("3")])
        let markdownTable = MarkdownTable(variant: .TrailingPipe, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "The first | 2nd       | 3              |",
            "--------- | --------- | -------------- |",
            "short     | long cell | very long cell |",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_LeadingPipes() {

        let table = createTable(
            cells: [["slightly longer", "long cell", "very long cell"]],
            headings: [.Text("The first"), .Text("2nd"), .Text("3")])
        let markdownTable = MarkdownTable(variant: .LeadingPipe, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "| The first       | 2nd       | 3             ",
            "| --------------- | --------- | --------------",
            "| slightly longer | long cell | very long cell",
            ]
        XCTAssertEqual(result, expectedRendition)
    }

    func testNormalization_SurroundingPipes() {

        let table = createTable(
            cells: [["foo", "bar cell", "baz"]],
            headings: [.Text("AA"), .Text("B"), .Text("CCCC")])
        let markdownTable = MarkdownTable(variant: .SurroundingPipes, tableContents: table)
        let normalizer = NormalizeMarkdownTable(table: markdownTable)

        let result = normalizer.renderedTable()

        let expectedRendition = [
            "| AA  | B        | CCCC |",
            "| --- | -------- | ---- |",
            "| foo | bar cell | baz  |",
            ]
        XCTAssertEqual(result, expectedRendition)
    }


    // MARK: RenderedColumnWidths

    /// When a `heading`=="", inserts .None.
    func createTable(cells cellData: [[String]], headings: [ColumnHeading]) -> Table {

        var cells: [Coordinates : CellData] = [:]

        for (rowIndex, row) in cellData.enumerate() {
            for (columnIndex, cell) in row.enumerate() {
                let coordinates = Coordinates(columnArrayIndex: columnIndex, rowArrayIndex: rowIndex)!
                cells[coordinates] = CellData.Text(cell)
            }
        }

        let columnHeadings: [Index : ColumnHeading] = headings.enumerate()
            .mapDictionary { (Index($0+1)!, $1) }

        let columnCount = UInt(cellData.first?.count ?? 0)
        let rowCount = UInt(cellData.count)

        return Table(
            tableSize: TableSize(columns: columnCount, rows: rowCount),
            cells: cells,
            columnHeadings: columnHeadings)
    }

    func testColumnWidth_BasedOnLongestCellInColumn() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hello"]],
            headings: [.Text("1"), .Text("2")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 5)
    }

    func testColumnWidth_WithPipeInLongestCellInColumn() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hel | lo"]],
            headings: [.Text("1"), .Text("2")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 9)
    }

    func testColumnWidth_With1Emoji_ForCellInColumn() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hello 🤔"]],
            headings: [.Text("1"), .Text("2")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 7)
    }

    func testColumnWidth_With2Emoji_ForCellInColumn() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hello 🤔x👍"]],
            headings: [.Text("1"), .Text("2")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 9)
    }

    func testColumnWidth_WithShrug_ForCellInColumn() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hi ¯\\_(ツ)_/¯"]],
            headings: [.Text("1"), .Text("2")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 12)
    }

    func testColumnWidth_BasedOnHeadingLength() {

        let table = createTable(
            cells: [["test", "b"], ["a", "hello"]],
            headings: [.Text("1"), .Text("sixths")])
        let markdownTable = MarkdownTable(variant: .Unknown, tableContents: table)

        let widths = RenderedColumnWidths(table: markdownTable)

        XCTAssertEqual(widths.columnWidth(index: Index(1)!), 4)
        XCTAssertEqual(widths.columnWidth(index: Index(2)!), 6)
    }

}
