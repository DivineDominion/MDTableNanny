import Foundation

/// Via Erica Sadun: Swift Developer's Cookbook.
///
/// Coerce to label/value output where possible
public protocol DefaultReflectable: CustomStringConvertible { }

extension DefaultReflectable {

    // Construct the description
    internal func DefaultDescription<T>(instance: T) -> String {
        // Establish mirror
        let mirror = Mirror(reflecting: instance)

        // Build label/value pairs where possible, otherwise
        // use default print output
        let chunks = mirror.children.map {
            (label: String?, value: Any) -> String in
            if let label = label {
                return "\(label)=\(value)"
            } else {
                return "\(value)"
            }
        }

        // Construct and return subject type / (chunks) string
        if chunks.count > 0 {
            let chunksString = chunks.joinWithSeparator(", ")
            return "\(mirror.subjectType)(\(chunksString))"
        } else {
            return "\(instance)"
        }
    }

    // Conform to CustomStringConvertible
    public var description: String { return DefaultDescription(self) }
}
