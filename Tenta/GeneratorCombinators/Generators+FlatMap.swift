import Foundation

extension Generators {

    public struct FlatMap<Upstream: Generator, Downstream: Generator>: Generator {
        public var transform: (Upstream.ValueToTest) -> Downstream
        public var upstream: Upstream

        public init(upstream: Upstream, transform: @escaping (Upstream.ValueToTest) -> Downstream) {
            self.upstream = upstream
            self.transform = transform
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Downstream.ValueToTest> {
            let roseTree = upstream.generate(size, &rng)

            let newRng = rng.clone()

            return roseTree.flatMap { generatedValue in
                var newRng = newRng
                return transform(generatedValue).generate(size, &newRng)
            }
        }
    }
}

extension Generator {
    public func flatMap<Downstream: Generator>(_ transform: @escaping (ValueToTest) -> Downstream) -> Generators.FlatMap<Self, Downstream> {
        Generators.FlatMap(upstream: self, transform: transform)
    }
}

//extension Generators.FlatMap {
//    public func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generators.FlatMap<Upstream, Transformed> {
//        Generators.FlatMap(upstream: self.upstream, transform: { x in transform(self.transform(x)) } )
//    }
//}
