import Foundation

extension Generators {

    public struct Always<ValueToTest>: Generator {
        public let value: ValueToTest

        public init(value: ValueToTest) {
            self.value = value
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
            RoseTree<ValueToTest>(root: value)
        }
    }

    public static func always<ValueToTest>(_ value: ValueToTest) -> Always<ValueToTest> {
        Always(value: value)
    }
}
