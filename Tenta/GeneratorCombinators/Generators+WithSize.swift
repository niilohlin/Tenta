import Foundation

extension Generators {

    public struct WithSize<G: Generator>: Generator {

        private let createGeneratorWithSize: (Size) -> G
        public init(createGeneratorWithSize: @escaping (Size) -> G) {
            self.createGeneratorWithSize = createGeneratorWithSize
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<G.ValueToTest> {
            createGeneratorWithSize(size).generate(size, &rng)
        }
    }


    /// Create a generator which depend on the size.
    static func withSize<G: Generator>(_ createGeneratorWithSize: @escaping (Size) -> G) -> WithSize<G> {
        WithSize(createGeneratorWithSize: createGeneratorWithSize)
    }
}
