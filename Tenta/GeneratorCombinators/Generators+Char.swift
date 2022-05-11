import Foundation

extension Generators {

    public struct CharGenerator: Generator {

        public init() {
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Character> {
            if size <= 0 {
                return RoseTree(root: Character(UnicodeScalar(32)), forest: [])
            }
            let range = 32 ... UInt8(truncatingIfNeeded: size + 32)
            let value = UInt8.random(in: range, using: &rng)
            let zero: UInt8 = 0
            return RoseTree(
                root: Character(UnicodeScalar(value)),
                forest: zero.shrinkFrom(source: value).map { tree in
                    tree.map { Character(UnicodeScalar($0)) }
                }
            )
        }
    }
}

extension Generators {
    static var char: Generators.CharGenerator {
        Generators.CharGenerator()
    }
}
