import Foundation

/// Exposes utility methods to obtain column heading and cell
/// contents with default escaping rules applied.
protocol EscapedTableRepresentation: TableRepresentation {

    func escapedColumnHeadingContent(column index: Index) -> String
    func escapedCellContent(coordinates: Coordinates) -> String

    // Overrides `TableRepresentation` default implementation.
    func select(row rowIndex: Index) -> Row
}

extension MarkdownTable: EscapedTableRepresentation { }


// MARK: Default implementations

extension EscapedTableRepresentation {

    func escapedColumnHeadingContent(column index: Index) -> String {

        return columnHeading(index)?.escaped.content ?? ""
    }

    func escapedCellContent(coordinates: Coordinates) -> String {

        return cellData(coordinates)?.escaped.content ?? ""
    }

    func select(row rowIndex: Index) -> Row {

        let cells = tableData.select(rowIndex: rowIndex).mapDictionary { (index, cellData) -> (Index, CellData) in

            return (index, cellData.escaped)
        }

        return Row(cells: cells)
    }
}


// MARK: Escaped content parts

private extension CellData {

    var escaped: CellData {

        switch self {
        case .Empty: return .Empty
        case .Text(let text): return .Text(MDTableNanny.escaped(content: text))
        }
    }
}

private extension ColumnHeading {

    var escaped: ColumnHeading {

        switch self {
        case .None: return .None
        case .Text(let text): return .Text(MDTableNanny.escaped(content: text))
        }
    }
}

private func escaped(content content: String?) -> String {

    guard let content = content else { return "" }

    func escapePipes(string: String) -> String {

        return string.stringByReplacingOccurrencesOfString("|", withString: "\\|")
    }
    
    return content |> escapePipes
}
