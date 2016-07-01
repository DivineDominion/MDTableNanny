import Foundation

extension Array {
    
    subscript (safe index: UInt) -> Element? {
        return self[safe: Int(index)]
    }

    subscript (index: UInt) -> Element {
        return self[Int(index)]
    }

    func appended(newElement: Element) -> Array<Element> {

        var result = self
        result.append(newElement)
        return result
    }
}
