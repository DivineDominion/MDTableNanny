import XCTest
@testable import MDTableNanny

class MarkdownTokenizerTests: XCTestCase {

    var tokenizer: MarkdownTokenizer!

    let simpleFixtureURL: NSURL! = NSBundle(forClass: MarkdownImporterTests.self).URLForResource("simple", withExtension: "md")
    let multipleFixtureURL: NSURL! = NSBundle(forClass: MarkdownImporterTests.self).URLForResource("multiple", withExtension: "md")

    override func setUp() {

        super.setUp()

        tokenizer = MarkdownTokenizer()

        precondition(hasValue(simpleFixtureURL), "simple.md expected")
        precondition(hasValue(multipleFixtureURL), "multiple.md expected")
    }

    func testTokenization_SimpleFixture() {

        let reader = try! StreamReader(URL: simpleFixtureURL)
        defer { reader.close() }

        guard let tokens = try? tokenizer.tokenize(stream: reader) else { XCTFail("should not throw"); return }

        XCTAssertEqual(tokens.count, 3)

        if let token = tokens[safe: 0],
            case let MarkdownTokenizer.Token.Text(lines) = token {

            XCTAssertEqual(lines.count, 4)
            XCTAssertEqual(lines[safe: 0], "# Lorem ipsum")
            XCTAssertEqual(lines[safe: 1], "")
            XCTAssertEqual(lines[safe: 2], "Dolor sit amet:")
            XCTAssertEqual(lines[safe: 3], "")
        } else {
            XCTFail("first token should be text")
        }

        if let token = tokens[safe: 1],
            case let MarkdownTokenizer.Token.Table(lines, hasHeader: hasHeader) = token {

            XCTAssert(hasHeader)
            XCTAssertEqual(lines.count, 4)
            XCTAssertEqual(lines[safe: 0], "| Heading 1 | Heading 2 |")
            XCTAssertEqual(lines[safe: 1], "| Cell 1-1  | Cell 2-1  |")
            XCTAssertEqual(lines[safe: 2], "|| Cell 2-2|")
            XCTAssertEqual(lines[safe: 3], "|Cell 1-3|Cell 2-3|")
        } else {
            XCTFail("second token should be table")
        }

        if let token = tokens[safe: 2],
            case let MarkdownTokenizer.Token.Text(lines) = token {

            XCTAssertEqual(lines.count, 2)
            XCTAssertEqual(lines, ["", "Consectetur!"])
        } else {
            XCTFail("third token should be text")
        }
    }

    func testTokenization_MultipleFixture() {

        let reader = try! StreamReader(URL: multipleFixtureURL)
        defer { reader.close() }

        guard let tokens = try? tokenizer.tokenize(stream: reader) else { XCTFail("should not throw"); return }

        XCTAssertEqual(tokens.count, 5)

        if let token = tokens[safe: 0],
            case let MarkdownTokenizer.Token.Text(lines) = token {

            XCTAssertEqual(lines.count, 6)
            XCTAssertEqual(lines[safe: 0], "Creating a table")
            XCTAssertEqual(lines[safe: 1], "------")
            XCTAssertEqual(lines[safe: 2], "")
            XCTAssertEqual(lines[safe: 3], "You can create tables with pipes `|` and hyphens `-`. Hyphens are used to create each column's header, while pipes separate each column.")
            XCTAssertEqual(lines[safe: 4], "")
            XCTAssertEqual(lines[safe: 5], "")
        } else {
            XCTFail("first token should be text")
        }

        if let token = tokens[safe: 1],
            case let MarkdownTokenizer.Token.Table(lines, hasHeader: hasHeader) = token {

            XCTAssert(hasHeader)
            XCTAssertEqual(lines.count, 3)
            XCTAssertEqual(lines[safe: 0], "First Header  | Second Header")
            XCTAssertEqual(lines[safe: 1], "Content Cell  | Content Cell")
            XCTAssertEqual(lines[safe: 2], "Content Cell  | Content Cell")
        } else {
            XCTFail("second token should be table")
        }

        if let token = tokens[safe: 2],
            case let MarkdownTokenizer.Token.Text(lines) = token {

            XCTAssertEqual(lines.count, 5)
            XCTAssertEqual(lines[safe: 0], "")
            XCTAssertEqual(lines[safe: 1], "The pipes on either end of the table are optional.")
            XCTAssertEqual(lines[safe: 2], "")
            XCTAssertEqual(lines[safe: 3], "Cells can vary in width and do not need to be perfectly aligned within columns. There must be at least three hyphens in each column of the header row.")
            XCTAssertEqual(lines[safe: 4], "")
        } else {
            XCTFail("third token should be text")
        }

        if let token = tokens[safe: 3],
            case let MarkdownTokenizer.Token.Table(lines, hasHeader: hasHeader) = token {

            XCTAssert(hasHeader)
            XCTAssertEqual(lines.count, 3)
            XCTAssertEqual(lines[safe: 0], "| Command | Description |")
            XCTAssertEqual(lines[safe: 1], "| `git status` | List all *new or modified* files |")
            XCTAssertEqual(lines[safe: 2], "| `git diff` | Show file differences that **haven't been** staged |")
        } else {
            XCTFail("fourth token should be table")
        }

        if let token = tokens[safe: 4],
            case let MarkdownTokenizer.Token.Text(lines) = token {

            XCTAssertEqual(lines.count, 8)
            XCTAssertEqual(lines[safe: 0], "")
            XCTAssertEqual(lines[safe: 1], "## Formatting content within your table")
            XCTAssertEqual(lines[safe: 2], "")
            XCTAssertEqual(lines[safe: 3], "You can use formatting such as links, inline code blocks, and text styling within your table:")
            XCTAssertEqual(lines[safe: 4], "")
            XCTAssertEqual(lines[safe: 5], "---")
            XCTAssertEqual(lines[safe: 6], "")
            XCTAssertEqual(lines[safe: 7], "via <https://help.github.com/articles/organizing-information-with-tables/>")
        } else {
            XCTFail("fifth token should be text")
        }
    }

    func testTokenization_Empty2x2Table() {

        let markdown = [
            "|   |   |",
            "|   |   |"
        ]

        guard let tokens = try? tokenizer.tokenize(stream: markdown) else { XCTFail("should not throw"); return }

        XCTAssertEqual(tokens.count, 1)

        if let token = tokens[safe: 0],
            case let MarkdownTokenizer.Token.Table(lines, hasHeader: hasHeader) = token {

            XCTAssertFalse(hasHeader)
            XCTAssertEqual(lines.count, 2)
            XCTAssertEqual(lines[safe: 0], "|   |   |")
            XCTAssertEqual(lines[safe: 1], "|   |   |")
        } else {
            XCTFail("first token should be table")
        }
    }
}
