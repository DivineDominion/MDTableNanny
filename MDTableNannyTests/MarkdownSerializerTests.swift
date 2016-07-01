import XCTest
@testable import MDTableNanny

class MarkdownSerializerTests: XCTestCase {

    func testRenderer_SingleCell_Has1Element() {

        let content = "the cell"
        let table = Table(
            tableSize: TableSize(columns: 1, rows: 1),
            cells: [Coordinates(column: 1, row: 1)! : CellData.Text(content)],
            columnHeadings: [:])
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 1)
        XCTAssertEqual(markdown.first, "| the cell |")
    }

    func testRenderer_1RowWithGapsBetween2Cells_Has1MarkdownTableRow() {

        let table = Table(
            tableSize: TableSize(columns: 4, rows: 1),
            cells: [
                Coordinates(column: 2, row: 1)! : CellData.Text("first"),
                Coordinates(column: 4, row: 1)! : CellData.Text("second")
            ],
            columnHeadings: [:])
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 1)
        XCTAssertEqual(markdown.first, "|   | first |   | second |")
    }

    func testRenderer_3RowsWithGapsBetweenCells_Generates3MarkdownTableRows() {

        let table = Table(
            tableSize: TableSize(columns: 4, rows: 3),
            cells: [
                Coordinates(column: 2, row: 1)! : CellData.Text("first"),
                Coordinates(column: 4, row: 1)! : CellData.Text("second"),

                Coordinates(column: 1, row: 3)! : CellData.Text("first"),
                Coordinates(column: 4, row: 3)! : CellData.Text("second")
            ],
            columnHeadings: [:])
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 3)
        let expectedResult = [
            "|       | first |   | second |",
            "|       |       |   |        |",
            "| first |       |   | second |"
        ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testRenderer_HeaderOnly_GeneratesMarkdownTableHeader() {

        let headings = [
            Index(1)! : ColumnHeading.Text("first"),
            Index(3)! : ColumnHeading.Text("second")
        ]
        let table = Table(tableSize: TableSize(columns: 4, rows: 0), columnHeadings: headings)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 2)
        let expectedResult = [
            "| first |   | second |   |",
            "| ----- | - | ------ | - |"
        ]
        XCTAssertEqual(markdown, expectedResult)
    }


    // MARK: Variant preservance

    let table = Table(
        tableSize: TableSize(columns: 4, rows: 3),
        cells: [
            Coordinates(column: 2, row: 1)! : CellData.Text("2"),
            Coordinates(column: 4, row: 1)! : CellData.Text("4"),

            Coordinates(column: 1, row: 3)! : CellData.Text("1"),
            Coordinates(column: 3, row: 3)! : CellData.Text("3")
        ],
        columnHeadings: [
            Index(1)! : ColumnHeading.Text("AAA"),
            Index(3)! : ColumnHeading.Text("CCC")
        ])

    func testGenericTable_GeneratesMarkdownTableWithPipes() {

        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "| AAA |   | CCC |   |",
            "| --- | - | --- | - |",
            "|     | 2 |     | 4 |",
            "|     |   |     |   |",
            "| 1   |   | 3   |   |",
        ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testMarkdownTable_NoPipes_GeneratesMarkdownTableWithoutPipes() {

        let table = MarkdownTable(variant: .NoPipes, tableContents: self.table)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "AAA |   | CCC |  ",
            "--- | - | --- | -",
            "    | 2 |     | 4",
            "    |   |     |  ",
            "1   |   | 3   |  ",
            ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testMarkdownTable_LeadingPipes_GeneratesMarkdownTableWithLeadingPipes() {

        let table = MarkdownTable(variant: .LeadingPipe, tableContents: self.table)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "| AAA |   | CCC |  ",
            "| --- | - | --- | -",
            "|     | 2 |     | 4",
            "|     |   |     |  ",
            "| 1   |   | 3   |  ",
            ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testMarkdownTable_TrailingPipes_GeneratesMarkdownTableWithTrailingPipes() {

        let table = MarkdownTable(variant: .TrailingPipe, tableContents: self.table)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "AAA |   | CCC |   |",
            "--- | - | --- | - |",
            "    | 2 |     | 4 |",
            "    |   |     |   |",
            "1   |   | 3   |   |",
            ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testMarkdownTable_SurroundingPipes_GeneratesMarkdownTableWithSurroundingPipes() {

        let table = MarkdownTable(variant: .SurroundingPipes, tableContents: self.table)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "| AAA |   | CCC |   |",
            "| --- | - | --- | - |",
            "|     | 2 |     | 4 |",
            "|     |   |     |   |",
            "| 1   |   | 3   |   |",
            ]
        XCTAssertEqual(markdown, expectedResult)
    }

    func testMarkdownTable_UnknownVariant_GeneratesMarkdownTableWithTrailingPipes() {

        let table = MarkdownTable(variant: .Unknown, tableContents: self.table)
        let markdown = MarkdownSerializer().content(table: table)

        XCTAssertEqual(markdown.count, 5)
        let expectedResult = [
            "| AAA |   | CCC |   |",
            "| --- | - | --- | - |",
            "|     | 2 |     | 4 |",
            "|     |   |     |   |",
            "| 1   |   | 3   |   |",
            ]
        XCTAssertEqual(markdown, expectedResult)
    }
}
