import Foundation

typealias Lines = [String]

protocol CollectsToken {
    var hasHeader: Bool { get set }
    mutating func append(line: String)
    func result() -> MarkdownTokenizer.Token
}

class MarkdownTokenizer {

    let syntax: MarkdownSyntax

    init(syntax: MarkdownSyntax = MarkdownSyntax()) {

        self.syntax = syntax
    }

    enum Token {
        case Text(Lines)
        case Table(Lines, hasHeader: Bool)
    }

    struct CollectTableToken: CollectsToken {

        var buffer: Lines = []
        var hasHeader = false

        mutating func append(line: String) {

            buffer.append(line)
        }

        func result() -> MarkdownTokenizer.Token {

            return Token.Table(buffer, hasHeader: hasHeader)
        }
    }

    struct CollectTextToken: CollectsToken {

        var buffer: Lines = []

        /// Ignored
        var hasHeader = false

        mutating func append(line: String) {

            buffer.append(line)
        }

        func result() -> MarkdownTokenizer.Token {

            return Token.Text(buffer)
        }
    }

    func tokenize<T: SequenceType where T.Generator.Element == String>(stream stream: T) throws -> [Token] {

        var tokenCollector: CollectsToken?
        var tokens: [Token] = []
        let hasStarted = { hasValue(tokenCollector) && tokenCollector is CollectTableToken }

        func finishToken() {
            appendToken()
            tokenCollector = nil
        }

        func appendToken() {
            if let collector = tokenCollector {
                let token = collector.result()
                tokens.append(token)
            }
        }

        for line in stream {

            if !hasStarted() {

                if syntax.lineCanStartTable(line) {

                    finishToken()
                    tokenCollector = CollectTableToken()
                } else if !hasValue(tokenCollector) {
                    tokenCollector = CollectTextToken()
                }

                tokenCollector!.append(line)

            } else {

                guard !syntax.lineIsSeparator(line) else {

                    tokenCollector!.hasHeader = true
                    // skip line contents
                    continue
                }

                if syntax.lineCanEndTable(line) {

                    finishToken()
                    tokenCollector = CollectTextToken()
                }

                tokenCollector?.append(line)
            }
        }

        appendToken()

        return tokens
    }
}
