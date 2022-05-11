import Foundation

public typealias Size = UInt

public protocol Generator {
    associatedtype ValueToTest

    func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
}

extension Generator {

    /// Generate a value without its shrink tree.
    public func generateUsing(_ constructor: inout Constructor) -> ValueToTest {
        generate(constructor.size, &constructor.rng).root()
    }
}

public extension Generator {
    func eraseToAnyGenerator() -> AnyGenerator<ValueToTest> {
        AnyGenerator(generate: generate(_:_:))
    }

    /// Should only be used when combining large structs or classes.
    func generateWithoutShrinking(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> ValueToTest {
        generate(size, &rng).root()
    }
}
