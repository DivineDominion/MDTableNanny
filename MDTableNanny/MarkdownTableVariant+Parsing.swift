import Foundation

// MARK: Cell matching helper

extension MarkdownTableVariant {

    private struct RowRegex {

        let leading: String
        let body: String
        let trailing: String

        var pattern: String {
            return "\(leading)\(body)\(trailing)"
        }
    }

    private static let defaultRowBodyRegex = "([^\\|]*.*?)"
    private static let defaultRowRegex = RowRegex(
        leading: "^([ ]{0,3}\\|?)",
        body: defaultRowBodyRegex,
        trailing: "(\\|?)$"
    )

    /// Regular expression to match a cell properly.
    private var cellRegex: RowRegex {

        switch self {
        case MarkdownTableVariant.TrailingPipe:
            // Don't consume leading pipes in the leading group.
            // These are delimiters in a "trailing" table.
            return RowRegex(
                leading: "^([^\\|]*?)",
                body: MarkdownTableVariant.defaultRowBodyRegex,
                trailing: "(\\|?)$"
            )

        default: return MarkdownTableVariant.defaultRowRegex
        }
    }
}


// MARK: Row Components

extension MarkdownTableVariant {

    static func recognizeVariant(row: String) -> MarkdownTableVariant {
        
        return RowComponents(row: row, cellRegex: MarkdownTableVariant.defaultRowRegex)?.recognizedVariant ?? .Unknown
    }

    func components(row: String) -> RowComponents? {

        return RowComponents(row: row, cellRegex: self.cellRegex)
    }

    struct RowComponents {

        let leading: String
        let body: String
        let trailing: String

        private init?(row: String, cellRegex: RowRegex) {

            let matches = row.regexGroupMatches(cellRegex.pattern)

            guard matches.count == 3 else {
                return nil
            }

            self.leading = matches[0]
            self.body = matches[1]
            self.trailing = matches[2]
        }

        var cellsFromBody: [String] {

            return body.split(regex: "(?<!\\\\)\\|")
                .map { $0.stringByTrimmingWhitespace() }
                .map(unescapePipes)
        }

        private func unescapePipes(string: String) -> String {

            return string.stringByReplacingOccurrencesOfString("\\|", withString: "|")
        }

        var recognizedVariant: MarkdownTableVariant {

            func componentIsEmpty(match: String) -> Bool {

                return match.isEmpty ?? true
            }

            var result: MarkdownTableVariant = []

            func addVariantIfPresent(match: String, variant: MarkdownTableVariant) {

                guard !componentIsEmpty(match) else { return }

                result.insert(variant)
            }
            
            addVariantIfPresent(leading, variant: .LeadingPipe)
            addVariantIfPresent(trailing, variant: .TrailingPipe)
            
            return result
        }
    }
}
