import Foundation

extension Generators {

    public struct Simple<ValueToTest>: Generator {
        public let generateValue: (inout Constructor) -> ValueToTest

        public init(generateValue: @escaping (inout Constructor) -> ValueToTest) {
            self.generateValue = generateValue
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
            var constructor = Constructor(size: size, rng: &rng)
            let value = generateValue(&constructor)
            return RoseTree<ValueToTest>(root: value)
        }
    }

    /// Construct a generator without any shrinking. Very simple to do and good for large structs and classes.
    public static func simple<ValueToTest>(generateValue: @escaping (inout Constructor) -> ValueToTest) -> Simple<ValueToTest> {
        Simple(generateValue: generateValue)
    }
}
