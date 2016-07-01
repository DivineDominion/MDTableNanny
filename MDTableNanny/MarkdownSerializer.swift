import Foundation

class MarkdownSerializer {

    init() { }
    
    func data(tables tables: MultipleTables) -> NSData? {

        let text = self.string(tables: tables)
        return text.dataUsingEncoding(NSUTF8StringEncoding)
    }

    func string(tables tables: MultipleTables) -> String {

        let content = self.content(tables: tables)
        return content.joinWithSeparator(String.newline)
    }

    func content(tables tables: MultipleTables) -> [String] {

        return Array(tables.rowStream())
    }
}
