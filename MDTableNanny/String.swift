import Foundation

extension String {

    static var newline: String { return "\n" }
    static var tab: String { return "\t" }
}

extension String {

    /// via <http://stackoverflow.com/a/30199503/1460929>
    func regexGroupMatches(pattern: String) -> [String] {

        guard let re = try? NSRegularExpression(pattern: pattern, options: []) else {

            return []
        }

        let nsString = self as NSString
        let results = re.matchesInString(self, options: [], range: NSRange(location: 0, length: nsString.length))

        return results.flatMap { result in
            // 0: full match
            // 1...n: group matches
            (1 ..< result.numberOfRanges).map { index in
                nsString.substringWithRange(result.rangeAtIndex(index))
            }
        }
    }

    func split(regex pattern: String) -> [String] {

        guard let re = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }

        let nsString = self as NSString
        let stop = "<<<SomeStringThatYouDoNotExpectToOccurInSelf>>>"
        let modifiedString = re.stringByReplacingMatchesInString(
            self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.componentsSeparatedByString(stop)
    }

    func stringByTrimmingWhitespace() -> String {

        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
