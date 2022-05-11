import Foundation

extension Generators {

    public struct IntGenerator: Generator {

        public init() {
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Swift.Int> {
            if size <= 0 {
                return RoseTree(root: 0, forest: [])
            }
            let range = -Int(size) ... Int(size)
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: value, forest: 0.shrinkFrom(source: value))
        }
    }
}

extension Generators {
    /**
     Generates an `Int`s and shrinks towards 0.

     Usage:
     ```
     testProperty(generator: AnyGenerator<Int>.int) { int in int % 1 == 0 }
     ```
     - Returns: A generator that generates `Int`s.
     */
    static var int: Generators.IntGenerator {
        Generators.IntGenerator()
    }
}
