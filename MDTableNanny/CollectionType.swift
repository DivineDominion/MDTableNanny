import Foundation

extension CollectionType where Self.Index : Comparable {

    subscript (safe index: Self.Index) -> Self.Generator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
