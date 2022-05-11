import Foundation

extension Generators {

    public struct UIntGenerator: Generator {

        public init() {
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<UInt> {
            if size <= 0 {
                return RoseTree(root: 0, forest: [])
            }
            let range = 0 ... UInt(size)
            let value = UInt.random(in: range, using: &rng)
            let zero: UInt = 0
            return RoseTree(root: value, forest: zero.shrinkFrom(source: value))
        }
    }

    public struct UInt8Generator: Generator {

        public init() {
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<UInt8> {
            if size <= 0 {
                return RoseTree(root: 0, forest: [])
            }
            let range = 0 ... UInt8(size)
            let value = UInt8.random(in: range, using: &rng)
            let zero: UInt8 = 0
            return RoseTree(root: value, forest: zero.shrinkFrom(source: value))
        }
    }
}

extension Generators {
    static var uInt: Generators.UIntGenerator {
        Generators.UIntGenerator()
    }

    static var uInt8: Generators.UInt8Generator {
        Generators.UInt8Generator()
    }
}
