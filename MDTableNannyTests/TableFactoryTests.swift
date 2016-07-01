import XCTest
@testable import MDTableNanny

class TableFactoryTests: XCTestCase {

    var factory: TableFactory!

    override func setUp() {

        super.setUp()

        factory = TableFactory()
    }

    func testTable_EmptyArray_ReturnsEmptyTable() {

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [])
        }

        XCTAssertNotNil(result)
        if let result = result {
            XCTAssertEqual(result, Table())
        }
    }

    func testTable_EmptyRowsInColumn_ReturnsTableWithSingleColumn() {

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [TableFactory.ColumnData(heading: .None, rows: [])])
        }

        XCTAssertNotNil(result)
        if let result = result {
            let expectedTable = Table(
                tableSize: TableSize(columns: 1, rows: 0),
                cells: [ : ])
            XCTAssertEqual(result, expectedTable)
        }
    }

    func testTable_EmptyRowsInColumnWithTitle_ReturnsTableWithTitledColumn() {

        let title = "the column title"

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [TableFactory.ColumnData(heading: .Text(title), rows: [])])
        }

        XCTAssertNotNil(result)
        if let result = result {
            let expectedTable = Table(
                tableSize: TableSize(columns: 1, rows: 0),
                cells: [ : ],
                columnHeadings: [ Index(1)! :.Text(title) ])

            XCTAssertEqual(result, expectedTable)
        }
    }

    func testTable_ColumnWithRow_DelegatesToCellFactory() {

        let cellFactoryDouble = TestCellFactory()
        factory = TableFactory(cellFactory: cellFactoryDouble)

        let rowContent = "content"

        ignoreError { () -> Void in
            _ = try factory.table(data: [TableFactory.ColumnData(heading: .None, rows: [rowContent])])
        }

        XCTAssert(hasValue(cellFactoryDouble.didCreateCellWith))
        if let value = cellFactoryDouble.didCreateCellWith {
            XCTAssert(value.object as? String == rowContent)
            XCTAssertEqual(value.column.value, 1)
            XCTAssertEqual(value.row.value, 1)
        }
    }

    func testTable_TitledColumnWithARow_ReturnsTableWithTitledColumnAndRow() {

        let title = "column title"
        let rowContent = "test content"

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [TableFactory.ColumnData(heading: .Text(title), rows: [rowContent])])
        }

        XCTAssertNotNil(result)
        if let result = result {
            let expectedTable = Table(
                tableSize: TableSize(columns: 1, rows: 1),
                cells: [ Coordinates(column: Index(1)!, row: Index(1)!) : .Text(rowContent) ],
                columnHeadings: [Index(1)! : .Text(title)])

            XCTAssertEqual(result, expectedTable)
        }
    }

    func testTable_TitledColumnWithRowsWithGaps_ReturnsTableWithTitledColumnAndCells() {

        let title = "the title"

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [TableFactory.ColumnData(heading: .Text(title), rows: ["first", nil, nil, nil, "fifth"])])
        }

        XCTAssertNotNil(result)
        if let result = result {
            let expectedTable = Table(
                tableSize: TableSize(columns: 1, rows: 5),
                cells: [
                    Coordinates(column: Index(1)!, row: Index(1)!) : .Text("first"),
                    Coordinates(column: Index(1)!, row: Index(5)!) : .Text("fifth")
                ],
                columnHeadings: [ Index(1)! : .Text(title) ])

            XCTAssertEqual(result, expectedTable)
        }
    }

    func testTable_ComplexTable_ReturnsTableContents() {

        var result: Table?
        expectNoError { () -> Void in
            result = try factory.table(data: [
                TableFactory.ColumnData(heading: .Text("first column"), rows: ["1", nil, "3"]),
                TableFactory.ColumnData(heading: .Text("second column"), rows: [nil, "2", nil, nil, nil, "6"])
                ])
        }

        XCTAssertNotNil(result)
        if let result = result {
            let expectedTable = Table(
                tableSize: TableSize(columns: 2, rows: 6),
                cells: [
                    Coordinates(column: Index(1)!, row: Index(1)!) : .Text("1"),
                    Coordinates(column: Index(1)!, row: Index(3)!) : .Text("3"),
                    Coordinates(column: Index(2)!, row: Index(2)!) : .Text("2"),
                    Coordinates(column: Index(2)!, row: Index(6)!) : .Text("6")
                ],
                columnHeadings: [
                    Index(1)! : .Text("first column"),
                    Index(2)! : .Text("second column")
                ])

            XCTAssertEqual(result, expectedTable)
        }
    }

    // MARK: -

    class TestCellFactory: CellFactory {

        var testCell = NewCell(column: Index(1)!, row: Index(1)!, data: .Text("irrelevant"))
        var didCreateCellWith: (object: AnyObject, column: Index, row: Index)?
        override func newCell(object: AnyObject, column: Index, row: Index) throws -> NewCell {

            didCreateCellWith = (object, column, row)

            return testCell
        }
    }
}
