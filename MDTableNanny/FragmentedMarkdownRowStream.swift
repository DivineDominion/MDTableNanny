import Foundation

class FragmentedMarkdownRowStream {

    let parts: [MarkdownPart]

    init(parts: [MarkdownPart]) {

        self.parts = parts
    }
}

extension FragmentedMarkdownRowStream: SequenceType {

    func generate() -> AnyGenerator<String> {

        let partsLines = parts.lazy.map(renderedPart).flatten()

        return AnyGenerator(partsLines.generate())
    }

    func renderedPart(part: MarkdownPart) -> [String] {

        switch part {
        case let .Text(lines): return lines
        case let .Table(markdownTable): return NormalizeMarkdownTable(table: markdownTable).renderedTable()
        }
    }
}
