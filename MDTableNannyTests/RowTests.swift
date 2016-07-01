import XCTest
@testable import MDTableNanny

class RowTests: XCTestCase {

    let irrelevantIndex = Index(1)!
    let irrelevantCellData = CellData.Text("irrelevant")

    func testCanShrink_EmptyRow_To1_ReturnsTrue() {

        let row = Row()

        XCTAssertTrue(row.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_EmptyRow_To100_ReturnsTrue() {

        let row = Row()

        XCTAssertTrue(row.canShrinkToIndex(Index(100)!))
    }


    func testCanShrink_WithFirstColumn_To1_ReturnsTrue() {

        let row = Row(cells: [
            Index(1)! : irrelevantCellData
            ])

        XCTAssertTrue(row.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_With100thColumn_To1_ReturnsFalse() {

        let row = Row(cells: [
            Index(100)! : irrelevantCellData
            ])

        XCTAssertFalse(row.canShrinkToIndex(Index(1)!))
    }

    func testCanShrink_With100thColumn_To100_ReturnsTrue() {

        let row = Row(cells: [
            Index(100)! : irrelevantCellData
            ])
        
        XCTAssertTrue(row.canShrinkToIndex(Index(100)!))
    }

}
