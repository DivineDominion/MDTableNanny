import XCTest
@testable import MDTableNanny

class TableSizeTests: XCTestCase {

    let irrelevantCoordinates = Coordinates(column: Index(33)!, row: Index(123)!)

    func testIncluding_EmptySize_ReturnsFalse() {

        XCTAssertFalse(TableSize().includes(coordinates: irrelevantCoordinates))
    }

    func testIncluding_ColumnOutOfRange_ReturnsFalse() {

        let size = TableSize(columns: 6, rows: 77)

        XCTAssertFalse(size.includes(coordinates: Coordinates(column: Index(7)!, row: Index(10)!)))
    }

    func testIncluding_RowOutOfRange_ReturnsFalse() {

        let size = TableSize(columns: 3, rows: 9)

        XCTAssertFalse(size.includes(coordinates: Coordinates(column: Index(1)!, row: Index(15)!)))
    }

    func testIncluding_BothInsideRange_ReturnsTrue() {

        let size = TableSize(columns: 8, rows: 5)

        XCTAssertTrue(size.includes(coordinates: Coordinates(column: Index(7)!, row: Index(3)!)))
    }
    
}
