import Foundation

/// Starts at `Index.first` and stops only if you break enumeration -- or if 
/// you `zip` it with another sequence, say:
///
///    let indexed = zip(InfiniteIndexSequence, [1, 2, 3, 4])
///    // => [(Index(1), 1), ... , (Index(4), 4)]
///
struct InfiniteIndexSequence: SequenceType {

    func generate() -> AnyGenerator<Index> {

        var current = Index.first

        return AnyGenerator {

            let result = current
            current = current.successor()

            return result
        }
    }
}

extension SequenceType {

    /// Like `enumerate`, only that it zips the elements with
    /// `Index`es instead of 0-based `Int`s.
    func indexedElements() -> Zip2Sequence<InfiniteIndexSequence, Self> {

        return zip(InfiniteIndexSequence(), self)
    }
}

extension CollectionType where Self.Index == MDTableNanny.Index {

    /// Like `enumerate`, only that it zips the elements with
    /// this collection's `Index`es instead of 0-based `Int`s.
    func indexedElements() -> Zip2Sequence<Range<MDTableNanny.Index>, Self> {
        
        return zip(self.indices, self)
    }
}
