import Foundation

class MarkdownSyntax {

    init() { }

    func lineCanStartTable(line: String) -> Bool {

        // Must not be indented as a code block (4 spaces)
        // Must not be empty
        // Pipes must not be surrounded by backticks
        let pattern = "^([ ]{0,3}).*?(?!`)\\|(?!`).*$\n?"

        return hasValue(line.rangeOfString(pattern, options: .RegularExpressionSearch))
    }

    func lineCanEndTable(line: String) -> Bool {

        guard !line.isEmpty else {
            return true
        }

        let pattern = "^(?!(" // Contains no ...
            + "(.*\\|.*)" // pipe
            + "|\\[.*\\]" // or [id] blocks
            + "|$" // or is empty
            + "))"

        return hasValue(line.rangeOfString(pattern, options: .RegularExpressionSearch))
    }

    private static let separatorContents = ["|", "-", " ", ":"]

    func lineIsSeparator(line: String) -> Bool {

        guard line.containsString("|") && line.containsString("-") else { return false }
        
        // Remove all valid separator chars from the line
        let nonSeparatorRemainder = MarkdownSyntax.separatorContents.reduce(line) { remainder, separatorChar in
            remainder.stringByReplacingOccurrencesOfString(separatorChar, withString: "")
        }
        
        return nonSeparatorRemainder.isEmpty
    }
}
