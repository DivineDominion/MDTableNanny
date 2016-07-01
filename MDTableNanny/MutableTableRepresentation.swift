import Foundation

protocol MutableTableRepresentation: TableRepresentation {

    mutating func insert(cell newCell: NewCell)
}
