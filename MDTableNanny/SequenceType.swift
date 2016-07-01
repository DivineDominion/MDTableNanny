import Foundation

extension SequenceType {

    func mapDictionary<K, V>(@noescape transform: (Self.Generator.Element) throws -> (K, V)) rethrows -> [K : V] {

        var result = [K : V]()

        for element in self {
            let (key, value) = try transform(element)
            result[key] = value
        }

        return result
    }

    func flatMapDictionary<K, V>(@noescape transform: (Self.Generator.Element) throws -> (K, V)?) rethrows -> [K : V] {

        var result = [K : V]()

        for element in self {
            if let (key, value) = try transform(element) {
                result[key] = value
            }
        }
        
        return result
    }
    
}
