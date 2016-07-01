import XCTest
@testable import MDTableNanny

class ColumnLensTests: XCTestCase {

    func testSubscript_EmptyTable_FirstCol_IsEmpty() {

        let lens = ColumnLens(table: createTable())

        XCTAssertNil(lens[safe: Index(1)!])
    }

    func testSubscript_EmptyTable_100thCol_IsEmpty() {

        let lens = ColumnLens(table: createTable())

        XCTAssertNil(lens[safe: Index(100)!])
    }

    func testSubscript_1x1Table_FirstCol_ReturnsColAt1stIndex() {

        let table = createTable(cells: [
            cell(column: 1, row: 1, text: "content")
            ].mapDictionary { $0 })

        let lens = ColumnLens(table: table)

        XCTAssertEqual(lens[Index(1)!][Index(1)!], .Text("content"))
    }

    func testSubscript_1x1Table_SecondCol_IsEmpty() {

        let table = createTable(cells: [
            cell(column: 1, row: 1, text: "irrelevant")
            ].mapDictionary { $0 })

        let lens = ColumnLens(table: table)

        XCTAssertNil(lens[safe: Index(100)!])
    }

    func testSubscript_1x3TableWithEmpty2ndRow_FirstCol_ReturnsRowAt1stAnd3rdIndexOnly() {

        let table = createTable(cells: [
            cell(column: 1, row: 1, text: "first"),
            cell(column: 1, row: 3, text: "second")
            ].mapDictionary { $0 })

        let lens = ColumnLens(table: table)

        let column = lens[Index(1)!]

        XCTAssertEqual(column[Index(1)!], .Text("first"))
        XCTAssertEqual(column[Index(3)!], .Text("second"))
    }

    // MARK: Sequence Indexes

    func testStart_6x3Table_Returns1() {

        let table = NullMutableTable()
        table.tableSize = TableSize(columns: 6, rows: 3)

        let lens = ColumnLens(table: table)

        XCTAssertEqual(lens.startIndex, Index(1)!)
    }

    func testEnd_2x3Table_Returns3() {

        let table = NullMutableTable()
        table.tableSize = TableSize(columns: 2, rows: 3)

        let lens = ColumnLens(table: table)

        XCTAssertEqual(lens.endIndex, Index(3)!)
    }


    // MARK: Heading

    func testHeading_ColumnWithHeading_IncludesHeadingInResult() {

        let heading = "the heading"
        let table = createTable(
            cells: [
                cell(column: 4, row: 1, text: "irrelevant")
            ].mapDictionary { $0 },
            columnHeadings: [ Index(4)! : .Text(heading) ]
        )

        let lens = ColumnLens(table: table)

        XCTAssertEqual(lens[Index(4)!].heading, ColumnHeading.Text(heading))
    }

    func testHeading_ColumnWithoutHeading_IncludesEmptyHeadingInResult() {

        let table = createTable(
            cells: [
                cell(column: 4, row: 1, text: "irrelevant")
            ].mapDictionary { $0 },
            columnHeadings: [ : ]
        )

        let lens = ColumnLens(table: table)

        XCTAssertEqual(lens[Index(4)!].heading, ColumnHeading.None)
    }


    // MARK: -

    func cell(column column: UInt, row: UInt, text: String) -> (Coordinates, CellData) {

        return (Coordinates(column: Index(column)!, row: Index(row)!), .Text(text))
    }

    func createTable(cells cells: [Coordinates : CellData] = [ : ], columnHeadings: [Index : ColumnHeading] = [ : ]) -> MarkdownTable {

        // Determine size by content
        let outermostCellCoord = cells.keys.sort { $0.column > $1.column && $0.row > $1.row }.last
        let tableSize = outermostCellCoord.map { TableSize(columns: $0.column.value, rows: $0.row.value) } ?? TableSize()

        return MarkdownTable(tableSize: tableSize, cells: cells, columnHeadings: columnHeadings)
    }

}
