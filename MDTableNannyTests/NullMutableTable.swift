import Foundation
@testable import MDTableNanny

class NullMutableTable: MutableTableRepresentation {

    var tableSize: TableSize = TableSize()
    var tableData: TableData = TableData()

    var columnInformation: ColumnInformation = ColumnInformation()

    lazy var rows: RowLens = RowLens(table: self)
    lazy var columns: ColumnLens = ColumnLens(table: self)

    func select(row rowIndex: Index) -> Row { return Row(cells: [ : ]) }

    func insert(cell newCell: NewCell) { }
    func cell(coordinates: Coordinates) -> CellData? { return nil }

    func changeColumnHeading(index index: Index, newHeading heading: ColumnHeading) { }
}
