import XCTest
@testable import MDTableNanny

private extension MarkdownContents {
    var firstTable: MarkdownTable? { return self.tables.first }
}

class MarkdownImporterTests: XCTestCase {

    var importer: MarkdownImporter!

    let simpleFixtureURL: NSURL! = NSBundle(forClass: MarkdownImporterTests.self).URLForResource("simple", withExtension: "md")
    let multipleFixtureURL: NSURL! = NSBundle(forClass: MarkdownImporterTests.self).URLForResource("multiple", withExtension: "md")

    override func setUp() {

        super.setUp()

        importer = MarkdownImporter()

        precondition(hasValue(simpleFixtureURL), "simple.md expected")
        precondition(hasValue(multipleFixtureURL), "multiple.md expected")
    }

    // MARK: Fixture tests
    
    func testImport_SimpleFixture_ReturnsTable() {

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(simpleFixtureURL)
        }

        guard let table = maybeContents?.firstTable else {
            XCTFail("table expected")
            return
        }

        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 3))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Heading 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Heading 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1-1"),
                Index(2)! : .Text("Cell 2-1")
            ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [ Index(2)! : .Text("Cell 2-2") ]))
        XCTAssertEqual(table.rows[Index(3)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1-3"),
                Index(2)! : .Text("Cell 2-3")
            ]))
    }

    func testImport_MultipleTableFixture_Returns2Tables() {

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(multipleFixtureURL)
        }

        XCTAssertEqual(maybeContents?.partsCount, 5)
        let maybeTablesOnly = maybeContents?.parts.filter {
            if case .Table(_) = $0 { return true }
            return false
        }
        XCTAssertEqual(maybeTablesOnly?.count, 2)
        let maybeTextsOnly = maybeContents?.parts.filter {
            if case .Text(_) = $0 { return true }
            return false
        }
        XCTAssertEqual(maybeTextsOnly?.count, 3)
    }

    func testImport_MultipleTableFixture_ReturnsFirstTable() {

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(multipleFixtureURL)
        }

        guard let part = maybeContents?[part: 1],
            case let MarkdownPart.Table(table) = part else {
            XCTFail("table expected")
            return
        }

        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("First Header"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Second Header"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Content Cell"),
                Index(2)! : .Text("Content Cell")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Content Cell"),
                Index(2)! : .Text("Content Cell")
                ]))
    }

    func testImport_MultipleTableFixture_ReturnsSecondTable() {

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(multipleFixtureURL)
        }

        guard let part = maybeContents?[part: 3],
            case let MarkdownPart.Table(table) = part else {
            XCTFail("table expected")
            return
        }

        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Command"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Description"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("`git status`"),
                Index(2)! : .Text("List all *new or modified* files")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("`git diff`"),
                Index(2)! : .Text("Show file differences that **haven't been** staged")
                ]))
    }

    // MARK: Weird contents

    func testImport_Empty2x2Table_ReturnsTableWithEmptyCells() {

        let markdown =
        "|   |   |\n" +
        "|   |   |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.SurroundingPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.rows[Index(1)!], Row(cells: [ : ]))
        XCTAssertEqual(table.rows[Index(2)!], Row(cells: [ : ]))
    }

    // MARK: - MDTest Compliance
    // via <https://github.com/michelf/mdtest/blob/master/PHP%20Markdown%20Extra.mdtest/Tables.text>

    // MARK: Simple table

    func testMDTest_1_Simple() {

        let markdown =
        "Header 1  | Header 2\n" +
        "--------- | ---------\n" +
        "Cell 1    | Cell 2\n" +
        "Cell 3    | Cell 4\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.NoPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_2_Simple_LeadingPipe() {

        let markdown =
        "| Header 1  | Header 2\n" +
        "| --------- | ---------\n" +
        "| Cell 1    | Cell 2\n" +
        "| Cell 3    | Cell 4\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_3_Simple_TailingPipe() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | --------- |\n" +
        "Cell 1    | Cell 2    |\n" +
        "Cell 3    | Cell 4    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_4_Simple_BothPipes() {

        let markdown =
        "| Header 1  | Header 2  |\n" +
        "| --------- | --------- |\n" +
        "| Cell 1    | Cell 2    |\n" +
        "| Cell 3    | Cell 4    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.SurroundingPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }


    // MARK: One-column one-row table

    func testMDTest_5_Minimal_LeadingPipe() {

        let markdown =
        "| Header\n" +
        "| -------\n" +
        "| Cell\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 1, rows: 1))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell")
                ]))
    }

    func testMDTest_6_Minimal_TailingPipe() {

        let markdown =
        "Header  |\n" +
        "------- |\n" +
        "Cell    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 1, rows: 1))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell")
                ]))
    }

    func testMDTest_7_Minimal_BothPipes() {

        let markdown =
        "| Header  |\n" +
        "| ------- |\n" +
        "| Cell    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.SurroundingPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 1, rows: 1))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell")
                ]))
    }

    // MARK: Empty Cells

    func testMDTest_10_Empty_BothPipes() {

        let markdown =
        "| Header 1  | Header 2  |\n" +
        "| --------- | --------- |\n" +
        "| A         | B         |\n" +
        "| C         |           |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.SurroundingPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_SecondCell_LeadingPipes() {

        let markdown =
        "| Header 1  | Header 2\n" +
        "| --------- | ---------\n" +
        "| A         | B\n" +
        "| C         | \n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_SecondCell_LeadingPipesCompacted() {

        let markdown =
        "| Header 1 | Header 2\n" +
        "| --- \n" +
        "| A | B\n" +
        "| C |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_SecondCell_LeadingPipesCompactedWithoutWhitespace() {

        let markdown =
        "|Header 1|Header 2\n" +
        "|---\n" +
        "|A|B\n" +
        "|C|\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_FirstCell_LeadingPipes() {

        let markdown =
        "| Header 1  | Header 2\n" +
        "| --------- | ---------\n" +
        "| A         | B\n" +
        "|           | D\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testEmpty_FirstCell_LeadingPipesCompacted() {

        let markdown =
        "| Header 1 | Header 2\n" +
        "| --- \n" +
        "| A | B\n" +
        "| | D\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testEmpty_FirstCell_LeadingPipesCompactedWithoutWhitespace() {

        let markdown =
        "|Header 1|Header 2\n" +
        "|---\n" +
        "|A|B\n" +
        "||D\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.LeadingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testEmpty_SecondCell_TrailingPipes() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | --------- |\n" +
        "A         | B         |\n" +
        "C         |           |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_SecondCell_TrailingPipesCompacted() {

        let markdown =
        "Header 1 | Header 2 |\n" +
        "--- |\n" +
        "A | B |\n" +
        "C | |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_SecondCell_TrailingPipesCompactedWithoutWhitespace() {

        let markdown =
        "Header 1|Header 2|\n" +
        "---|\n" +
        "A|B|\n" +
        "C||\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("C"),
                ]))
    }

    func testEmpty_FirstCell_TrailingPipes() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | --------- |\n" +
        "A         | B         |\n" +
        "          | D         |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testEmpty_FirstCell_TrailingPipesCompacted() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--- |\n" +
        "A | B |\n" +
        "  | D |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testEmpty_FirstCell_TrailingPipesCompactedWithoutWhitespace() {

        let markdown =
        "Header 1|Header 2|\n" +
        "---|\n" +
        "A|B|\n" +
        "|D|\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))
        
        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }

    func testMDTest_11_Empty_NoPipes() {

        let markdown =
        "Header 1  | Header 2\n" +
        "--------- | ---------\n" +
        "A         | B\n" +
        "          | D\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.NoPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("A"),
                Index(2)! : .Text("B")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(2)! : .Text("D"),
                ]))
    }


    // MARK: Missing tailing pipe

    func testMDTest_12_MissingTail_InHeader() {

        let markdown =
        "Header 1  | Header 2\n" +
        "--------- | --------- |\n" +
        "Cell 1    | Cell 2    |\n" +
        "Cell 3    | Cell 4    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.NoPipes)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_13_MissingTail_InSeparator() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | ---------\n" +
        "Cell 1    | Cell 2    |\n" +
        "Cell 3    | Cell 4    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_14_MissingTail_InFirstRow() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | --------- |\n" +
        "Cell 1    | Cell 2\n" +
        "Cell 3    | Cell 4    |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    func testMDTest_15_MissingTail_InSecondRow() {

        let markdown =
        "Header 1  | Header 2  |\n" +
        "--------- | --------- |\n" +
        "Cell 1    | Cell 2    |\n" +
        "Cell 3    | Cell 4\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.variant, MarkdownTableVariant.TrailingPipe)
        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }

    // MARK: Too many pipes in row

    func testMDTest_16_TooManyPipesInRow() {

        let markdown =
        "| Header 1  | Header 2 |\n" +
        "| --------- \n" +
        "| Cell 1    | Cell 2   | Extra cell? |\n" +
        "| Cell 3    | Cell 4   | Extra cell? |\n"

        var maybeContents: MarkdownContents?
        expectNoError {
            maybeContents = try importer.importMarkdown(markdown)
        }

        XCTAssertEqual(maybeContents?.partsCount, 2)
        guard let table = maybeContents?.firstTable else { XCTFail("table expected"); return }

        XCTAssertEqual(table.tableSize, TableSize(columns: 2, rows: 2))

        XCTAssertEqual(table.columnHeading(Index(1)!), ColumnHeading.Text("Header 1"))
        XCTAssertEqual(table.columnHeading(Index(2)!), ColumnHeading.Text("Header 2"))

        XCTAssertEqual(table.rows[Index(1)!],
            Row(cells: [
                Index(1)! : .Text("Cell 1"),
                Index(2)! : .Text("Cell 2")
                ]))
        XCTAssertEqual(table.rows[Index(2)!],
            Row(cells: [
                Index(1)! : .Text("Cell 3"),
                Index(2)! : .Text("Cell 4")
                ]))
    }
}
