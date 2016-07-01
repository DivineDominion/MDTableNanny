import XCTest
@testable import MDTableNanny

class ColumnTests: XCTestCase {

    let irrelevantIndex = Index(1)!
    let irrelevantCellData = CellData.Text("irrelevant")

    func testAnyCell_EmptyColumn_ReturnsNil() {

        XCTAssertNil(Column().cell(row: Index(123)!))
    }

    func testExistingCell_ReturnsCell() {

        let cellData = CellData.Text("content")
        let column = Column(cells: [
            Index(3)! : cellData
            ])

        let result = column.cell(row: Index(3)!)
        XCTAssertNotNil(result)
        if let result = result {
            XCTAssertEqual(result, cellData)
        }
    }

    func testCanShrink_EmptyColumn_To1_ReturnsTrue() {

        let column = Column()

        XCTAssertTrue(column.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_EmptyColumn_To100_ReturnsTrue() {

        let column = Column()

        XCTAssertTrue(column.canShrinkToIndex(Index(100)!))
    }


    func testCanShrink_WithFirstRow_To1_ReturnsTrue() {

        let column = Column(cells: [
            Index(1)! : irrelevantCellData
            ])

        XCTAssertTrue(column.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_With100thRow_To1_ReturnsFalse() {

        let column = Column(cells: [
            Index(100)! : irrelevantCellData
            ])

        XCTAssertFalse(column.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_With100thRow_To100_ReturnsTrue() {

        let column = Column(cells: [
            Index(100)! : irrelevantCellData
            ])

        XCTAssertTrue(column.canShrinkToIndex(Index(100)!))
    }
    
}
