import Foundation

extension Generators {

    public struct Map<Upstream: Generator, ValueToTest>: Generator {
        public var transform: (Upstream.ValueToTest) -> ValueToTest
        public var upstream: Upstream

        public init(upstream: Upstream, transform: @escaping (Upstream.ValueToTest) -> ValueToTest) {
            self.upstream = upstream
            self.transform = transform
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
            upstream.generate(size, &rng).map(transform)
        }
    }
}

extension Generator {
    public func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generators.Map<Self, Transformed> {
        Generators.Map(upstream: self, transform: transform)
    }
}

extension Generators.Map {
    public func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generators.Map<Upstream, Transformed> {
        Generators.Map(upstream: self.upstream, transform: { x in transform(self.transform(x)) } )
    }
}
