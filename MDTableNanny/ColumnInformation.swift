import Foundation

struct ColumnInformation {

    private(set) var columnHeadings: [Index : ColumnHeading]

    var isEmpty: Bool { return columnHeadings.isEmpty }
    
    init() {

        self.columnHeadings = [ : ]
    }

    init(columnHeadings: [Index : ColumnHeading]) {

        self.columnHeadings = columnHeadings
    }

    subscript (columnIndex: Index) -> ColumnHeading {

        get {
            return columnHeadings[columnIndex] ?? ColumnHeading.None
        }

        set {
            columnHeadings[columnIndex] = newValue
        }
    }

    mutating func replaceColumn(at index: Index, contents: ColumnContents) {

        columnHeadings[index] = contents.columnHeading ?? .None
    }

    mutating func insertColumn(before index: Index) {

        let columnsToMove = columnHeadings.filter { $0.0 >= index }
            .sort(descending)

        for (columnIndex, columnHeading) in columnsToMove {

            columnHeadings[columnIndex.successor()] = columnHeading
            columnHeadings[columnIndex] = nil
        }
    }

    mutating func removeColumn(at index: Index) {

        columnHeadings[index] = nil

        let columnsToMove = columnHeadings.filter { $0.0 > index }
            .sort(ascending)

        for (columnIndex, column) in columnsToMove {

            columnHeadings[columnIndex.predecessor()!] = column
            columnHeadings[columnIndex] = nil
        }
    }
}

extension ColumnInformation: Equatable { }

func ==(lhs: ColumnInformation, rhs: ColumnInformation) -> Bool {

    func textOnly(index: Index, columnHeading: ColumnHeading) -> Bool {

        return columnHeading != .None
    }

    let lFilteredHeadings = lhs.columnHeadings.filter(textOnly).mapDictionary { $0 }
    let rFilteredHeadings = rhs.columnHeadings.filter(textOnly).mapDictionary { $0 }

    return lFilteredHeadings == rFilteredHeadings
}
