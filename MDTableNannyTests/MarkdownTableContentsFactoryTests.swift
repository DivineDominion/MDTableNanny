import XCTest
@testable import MDTableNanny

class MarkdownTableContentsFactoryTests: XCTestCase {

    let factory = MarkdownTableContentsFactory()

    func testBuild_SingleCellTable() {

        let lines = ["| Sole Content Cell"]

        let result = factory.build(lines: lines, hasHeaders: false)

        XCTAssertEqual(result.tableSize, TableSize(columns: 1, rows: 1))
        XCTAssertEqual(result.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(result.columnData.count, 1)

        let expectedData = TableFactory.ColumnData(heading: .None, rows: ["Sole Content Cell"])
        XCTAssertEqual(result.columnData.first, expectedData)
    }

    func testBuild_HeaderCellsWithLotsOfWhitespaceAfterPipe() {

        let lines = ["| A  |  B |     ", " | some | content |  "]

        let result = factory.build(lines: lines, hasHeaders: true)

        XCTAssertEqual(result.tableSize, TableSize(columns: 2, rows: 1))
        XCTAssertEqual(result.variant, MarkdownTableVariant.SurroundingPipes)
        XCTAssertEqual(result.columnData.count, 2)

        let expectedFirstColumnData = TableFactory.ColumnData(heading: .Text("A"), rows: ["some"])
        let expectedSecondColumnData = TableFactory.ColumnData(heading: .Text("B"), rows: ["content"])
        XCTAssertEqual(result.columnData[safe: 0], expectedFirstColumnData)
        XCTAssertEqual(result.columnData[safe: 1], expectedSecondColumnData)
    }

    func testBuild_SingleCellWithHeadingTable() {

        let lines = ["Le heading", "| Sole Content Cell"]

        let result = factory.build(lines: lines, hasHeaders: true)

        XCTAssertEqual(result.tableSize, TableSize(columns: 1, rows: 1))
        XCTAssertEqual(result.variant, MarkdownTableVariant.NoPipes)
        XCTAssertEqual(result.columnData.count, 1)

        let expectedData = TableFactory.ColumnData(heading: .Text("Le heading"), rows: ["Sole Content Cell"])
        XCTAssertEqual(result.columnData.first, expectedData)
    }

    func testBuild_3x2CellTable() {

        let lines = ["A | B | C", "D | | F"]

        let result = factory.build(lines: lines, hasHeaders: false)

        XCTAssertEqual(result.tableSize, TableSize(columns: 3, rows: 2))
        XCTAssertEqual(result.variant, MarkdownTableVariant.NoPipes)
        XCTAssertEqual(result.columnData.count, 3)
        XCTAssertEqual(result.columnData[safe: 0], TableFactory.ColumnData(heading: .None, rows: ["A", "D"]))
        XCTAssertEqual(result.columnData[safe: 1], TableFactory.ColumnData(heading: .None, rows: ["B", nil]))
        XCTAssertEqual(result.columnData[safe: 2], TableFactory.ColumnData(heading: .None, rows: ["C", "F"]))
    }
}
