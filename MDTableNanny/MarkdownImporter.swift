import Foundation

class MarkdownImporter {

    let tokenizer: MarkdownTokenizer
    let parser: MarkdownParser

    init(tokenizer: MarkdownTokenizer = MarkdownTokenizer(), parser: MarkdownParser = MarkdownParser()) {

        self.tokenizer = tokenizer
        self.parser = parser
    }

    func importMarkdown(URL: NSURL, factory: TableFactory = TableFactory()) throws -> MarkdownContents {

        let reader = try StreamReader(URL: URL, encoding: NSUTF8StringEncoding)

        defer { reader.close() }

        let tokens = try tokenizer.tokenize(stream: reader)
        return try parser.parse(tokens: tokens, tableFactory: factory)
    }

    func importMarkdown(text: String, factory: TableFactory = TableFactory()) throws -> MarkdownContents {

        let lines = text.characters
            .split(allowEmptySlices: true) { $0 == Character(String.newline) }
            .map(String.init)

        let tokens = try tokenizer.tokenize(stream: lines)
        return try parser.parse(tokens: tokens, tableFactory: factory)
    }
}
