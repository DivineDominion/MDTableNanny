import Foundation

struct NewCell {

    let coordinates: Coordinates
    var row: Index { return coordinates.row }
    var column: Index { return coordinates.column }

    let data: CellData

    init(column: Index, row: Index, data: CellData) {

        self.coordinates = Coordinates(column: column, row: row)
        self.data = data
    }

    init(coordinates: Coordinates, data: CellData) {

        self.coordinates = coordinates
        self.data = data
    }

    @available(*, deprecated=1.0)
    func insert(table: MutableTableRepresentation) -> MutableTableRepresentation {

        var table = table
        table.insert(cell: self)

        return table
    }
}

extension NewCell: Equatable { }

func ==(lhs: NewCell, rhs: NewCell) -> Bool {

    return lhs.coordinates == rhs.coordinates && lhs.row == rhs.row && lhs.column == rhs.column && lhs.data == rhs.data
}
