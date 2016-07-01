import XCTest
@testable import MDTableNanny

class FragmentedMarkdownRowStreamTests: XCTestCase {

    func testStream_3PartDocument_ReturnsSequenceOfContentLines() {

        let table = MarkdownTable(
            tableSize: TableSize(columns: 2, rows: 2),
            cells: [
                Coordinates(column: 1, row: 1)! : .Text("33"),
                Coordinates(column: 2, row: 2)! : .Text("4"),
            ],
            columnHeadings: [
                Index(1)! : .Text("a")
            ])
        let parts: [MarkdownPart] = [
            .Text(["1", "2"]),
            .Table(table),
            .Text(["5", "6"]),
        ]
        let stream = FragmentedMarkdownRowStream(parts: parts)

        XCTAssertEqual(Array(stream).count, 8)
        let expectedText = [
            "1",
            "2",
            "| a  |   |",
            "| -- | - |",
            "| 33 |   |",
            "|    | 4 |",
            "5",
            "6"
        ]
        XCTAssertEqual(Array(stream), expectedText)
    }

}
