import Foundation

extension IntegerType {
    func times<T>(f: () -> T) -> [T] {
        return (0..<self).map { _ in f() }
    }
}
