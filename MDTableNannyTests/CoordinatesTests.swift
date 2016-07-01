import XCTest
@testable import MDTableNanny

class CoordinatesTests: XCTestCase {

    func testAdvanceColumn_4x5Coord_Returns5x5Coord() {

        XCTAssertEqual(
            Coordinates(column: 4, row: 5)!.move(.Right),
            Coordinates(column: 5, row: 5)!)
    }

    func testDeclineColumn_4x5Coord_Returns3x5Coord() {

        XCTAssertEqual(
            Coordinates(column: 4, row: 5)!.move(.Left),
            Coordinates(column: 3, row: 5)!)
    }

    func testDeclineColumn_1x3Coord_ReturnsNil() {

        XCTAssertNil(Coordinates(column: 1, row: 3)!.move(.Left))
    }

    func testAdvanceRow_2x19Coord_Returns2x20Coord() {

        XCTAssertEqual(
            Coordinates(column: 2, row: 19)!.move(.Down),
            Coordinates(column: 2, row: 20)!)
    }

    func testDeclineRow_9x12Coord_Returns9x11Coord() {

        XCTAssertEqual(
            Coordinates(column: 9, row: 12)!.move(.Up),
            Coordinates(column: 9, row: 11)!)
    }

    func testDeclineColumn_800x1Coord_ReturnsNil() {

        XCTAssertNil(Coordinates(column: 800, row: 1)!.move(.Up))
    }

}
