import Foundation

extension Generators {

    public struct Element<SequenceType: Sequence>: Generator {

        private let sequence: SequenceType
        public init(sequence: SequenceType) {
            self.sequence = sequence
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<SequenceType.Element> {
            var array = [SequenceType.Element]()
            var iterator = sequence.makeIterator()
            for _ in 0..<(size + 1) {
                if let nextElement = iterator.next() {
                    array.append(nextElement)
                } else {
                    break
                }
            }
            guard let element = array.randomElement(using: &rng) else {
                fatalError("Could not generate an element from an empty sequence")
            }
            return RoseTree<SequenceType.Element>(
                    root: element,
                    forest: array.map { RoseTree(root: $0) }
            )
        }

        // Might be faster
//        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<SequenceType.Element> {
//            var array = [SequenceType.Element]()
//            var iterator = sequence.makeIterator()
//            let index = Generators.uInt.generateWithoutShrinking(size, &rng)
//            for _ in 0..<max(1, min(index, UInt(size) + 1)) {
//                if let nextElement = iterator.next() {
//                    array.append(nextElement)
//                } else {
//                    break
//                }
//            }
//            guard let element = array.last else {
//                fatalError("Could not generate an element from an empty sequence")
//            }
//            return RoseTree<SequenceType.Element>(
//                    root: element,
//                    forest: array.map { RoseTree(root: $0) }
//            )
//        }
    }

    /// Create a generator that generate elements in `Sequence`
    static func element<SequenceType: Sequence>(from sequence: SequenceType) -> Element<SequenceType> {
        Element(sequence: sequence)
    }
}
