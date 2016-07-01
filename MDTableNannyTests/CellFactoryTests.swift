import XCTest
@testable import MDTableNanny

class CellFactoryTests: XCTestCase {

    var factory: CellFactory!

    override func setUp() {

        super.setUp()

        factory = CellFactory()
    }

    func testNewCell_WithText_ReturnsCell() {

        let content = "test"

        var maybeResult: NewCell?
        expectNoError { () -> Void in
            maybeResult = try factory.newCell(content, column: Index(8)!, row: Index(1)!)
        }

        guard let result = maybeResult else {
            XCTFail("expected result")
            return
        }

        XCTAssertEqual(result.data, CellData.Text(content))
        XCTAssertEqual(result.column.value, 8)
        XCTAssertEqual(result.row.value, 1)
    }

    func testNewCell_WithNumber_Throws() {

        do {
            _ = try factory.newCell(123, column: Index(4)!, row: Index(9)!)
        } catch {
            switch error {
            case let ImportError.UnsupportedCellType(column: column, row: row):
                XCTAssertEqual(column, 4)
                XCTAssertEqual(row, 9)

            default:
                XCTFail("unexpected error")
            }
            return
        }

        XCTFail("error expected")
    }

}
