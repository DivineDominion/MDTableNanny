import Foundation

struct MarkdownTableVariant: OptionSetType {

    let rawValue: Int

    static let Unknown = MarkdownTableVariant(rawValue: -1)

    static let NoPipes = MarkdownTableVariant(rawValue: 0)

    static let LeadingPipe = MarkdownTableVariant(rawValue: 1 << 0)
    static let TrailingPipe = MarkdownTableVariant(rawValue: 1 << 1)
    static let SurroundingPipes: MarkdownTableVariant = [LeadingPipe, TrailingPipe]

    var surroundingPipeCount: Int {

        return (self.contains(.LeadingPipe) ? 1 : 0)
            + (self.contains(.TrailingPipe) ? 1 : 0)
    }

    func embeddedInPipes(row row: String) -> String {

        let prefix: String = {
            guard self.contains(.LeadingPipe) else { return "" }
            return "| "
        }()

        let suffix: String = {
            guard self.contains(.TrailingPipe) else { return "" }
            return " |"
        }()

        return prefix + row + suffix
    }
}
