import XCTest
@testable import MDTableNanny

class MarkdownParserTests: XCTestCase {

    var parser: MarkdownParser!

    let factory = TableFactory()

    override func setUp() {

        super.setUp()

        parser = MarkdownParser()
    }
    
    func testParsing_TextOnly_ReturnsTextPart() {

        let text = ["asd", "fgh"]
        let token = MarkdownTokenizer.Token.Text(text)

        guard let result = try? parser.parse(tokens: [token], tableFactory: factory) else { XCTFail("expected not error"); return }

        XCTAssertEqual(result.partsCount, 1)
        let part = result[part: 0]
        if case let MarkdownPart.Text(lines) = part {
            XCTAssertEqual(lines, text)
        } else { XCTFail("text expected") }
    }

    func testParsing_TableOnly_ReturnsTablePart() {

        let text = ["header", "content 1", "content 2"]
        let token = MarkdownTokenizer.Token.Table(text, hasHeader: true)

        guard let result = try? parser.parse(tokens: [token], tableFactory: factory) else { XCTFail("expected no error"); return }

        XCTAssertEqual(result.partsCount, 1)
        let part = result[part: 0]
        if case let MarkdownPart.Table(table) = part {

            XCTAssertEqual(table.tableSize, TableSize(columns: 1, rows: 2))
            XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("header"))
            XCTAssertEqual(table.cellData(Coordinates(column: 1, row: 1)!), CellData.Text("content 1"))
            XCTAssertEqual(table.cellData(Coordinates(column: 1, row: 2)!), CellData.Text("content 2"))
        } else { XCTFail("table expected") }
    }

    func testParsing_TableWithEscapedPipes_ReturnsContentWithoutEscapingChar() {

        let text = ["head A | head B", "content 1 | content 2", "content \\| 3 | content 4"]
        let token = MarkdownTokenizer.Token.Table(text, hasHeader: true)

        guard let result = try? parser.parse(tokens: [token], tableFactory: factory) else { XCTFail("expected no error"); return }

        XCTAssertEqual(result.partsCount, 1)
        let part = result[part: 0]
        if case let MarkdownPart.Table(table) = part {

            XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))
            XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("head A"))
            XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("head B"))
            XCTAssertEqual(table.cellData(Coordinates(column: 1, row: 1)!), CellData.Text("content 1"))
            XCTAssertEqual(table.cellData(Coordinates(column: 2, row: 1)!), CellData.Text("content 2"))
            XCTAssertEqual(table.cellData(Coordinates(column: 1, row: 2)!), CellData.Text("content | 3"))
            XCTAssertEqual(table.cellData(Coordinates(column: 2, row: 2)!), CellData.Text("content 4"))
        } else { XCTFail("table expected") }
    }
}
