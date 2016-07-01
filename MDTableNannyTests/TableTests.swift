import XCTest
@testable import MDTableNanny

class TableTests: XCTestCase {

    func testEmptyTable_Has0x0Size() {

        XCTAssertEqual(Table().tableSize, TableSize(columns: 0, rows: 0))
    }
    

    // MARK: Inserting

    let irrelevantCellData = CellData.Text("irrelevant")
    let irrelevantIndex = Index(9)!

    func testInserting_EmptyTable_ReturnsEmptyTable() {

        let tablePrototype = Table()
        var table = tablePrototype
        let cell = NewCell(column: irrelevantIndex, row: irrelevantIndex, data: irrelevantCellData)
        table.insert(cell: cell)

        XCTAssertEqual(table, tablePrototype)
    }

    func testInserting_OutsideColumnBounds_ReturnsEmptyTableWithSameSize() {

        let tablePrototype = Table(tableSize: TableSize(columns: 10, rows: 100))
        var table = tablePrototype
        let cell = NewCell(column: Index(11)!, row: Index(5)!, data: irrelevantCellData)

        table.insert(cell: cell)

        XCTAssertEqual(table, tablePrototype)
    }

    func testInserting_OutsideRowBounds_ReturnsEmptyTableWithSameSize() {

        let tablePrototype = Table(tableSize: TableSize(columns: 10, rows: 100))
        var table = tablePrototype
        let cell = NewCell(column: Index(2)!, row: Index(101)!, data: irrelevantCellData)

        table.insert(cell: cell)

        XCTAssertEqual(table, tablePrototype)
    }

    func testInserting_InsideTableBounds_ReturnsDifferentTable() {

        let tablePrototype = Table(tableSize: TableSize(columns: 10, rows: 100))
        var table = tablePrototype
        let cell = NewCell(column: Index(6)!, row: Index(5)!, data: irrelevantCellData)

        table.insert(cell: cell)

        XCTAssertNotEqual(table, tablePrototype)
    }

    func testInserting_InsideTableBounds_ReturnsTableWithDataAtIndex() {

        let coordinates = Coordinates(column: Index(2)!, row: Index(5)!)
        let data = CellData.Text("the content!")
        var table = Table(tableSize: TableSize(columns: 10, rows: 100))

        table.insert(cell: NewCell(coordinates: coordinates, data: data))

        XCTAssertNotNil(table.cellData(coordinates))
        if let value = table.cellData(coordinates) {
            XCTAssertEqual(value, data)
        }
    }
}
