import XCTest
@testable import MDTableNanny

class RowLensTests: XCTestCase {

    func testSubscript_EmptyTable_FirstRow_IsEmpty() {

        let lens = RowLens(table: Table(tableSize: TableSize()))

        XCTAssert(lens[Index(1)!].isEmpty)
    }

    func testSubscript_EmptyTable_100thRow_IsEmpty() {

        let lens = RowLens(table: Table(tableSize: TableSize()))

        XCTAssert(lens[Index(100)!].isEmpty)
    }

    func testSubscript_1x1Table_FirstRow_ReturnsRowAt1stIndex() {

        let table = Table(cells: [
            cell(column: 1, row: 1, text: "content")
            ].mapDictionary { $0 }, tableSize: TableSize(columns: 1, rows: 1))

        let lens = RowLens(table: table)

        XCTAssertEqual(lens[Index(1)!].count, 1)
        XCTAssertEqual(lens[Index(1)!][Index(1)!], .Text("content"))
    }

    func testSubscript_1x1Table_SecondRow_IsEmpty() {

        let table = Table(cells: [
            cell(column: 1, row: 1, text: "irrelevant")
            ].mapDictionary { $0 }, tableSize: TableSize(columns: 1, rows: 1))

        let lens = RowLens(table: table)

        XCTAssert(lens[Index(100)!].isEmpty)
    }

    func testSubscript_3x1TableWithEmpty2ndColumn_FirstRow_ReturnsRowAt1stAnd3rdIndexOnly() {

        let table = Table(cells: [
            cell(column: 1, row: 1, text: "first"),
            cell(column: 3, row: 1, text: "second")
            ].mapDictionary { $0 }, tableSize: TableSize(columns: 3, rows: 1))

        let lens = RowLens(table: table)

        let row = lens[Index(1)!]

        XCTAssertEqual(row.count, 2)
        XCTAssertEqual(row[Index(1)!], .Text("first"))
        XCTAssertEqual(row[Index(3)!], .Text("second"))
    }


    // MARK: Sequence Indexes

    func testStart_6x3Table_Returns1() {

        let table = Table(tableSize: TableSize(columns: 6, rows: 3))

        let lens = RowLens(table: table)

        XCTAssertEqual(lens.startIndex, Index(1)!)
    }

    func testEnd_2x3Table_Returns4() {

        let table = Table(tableSize: TableSize(columns: 2, rows: 3))

        let lens = RowLens(table: table)

        XCTAssertEqual(lens.endIndex, Index(4)!)
    }


    // MARK: -

    func cell(column column: UInt, row: UInt, text: String) -> (Coordinates, CellData) {

        return (Coordinates(column: Index(column)!, row: Index(row)!), .Text(text))
    }
}
