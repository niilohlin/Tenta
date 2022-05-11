import Foundation

extension Generators {

    public struct OverrideRoseTree<Upstream: Generator>: Generator {

        let shrink: (Upstream.ValueToTest) -> RoseTree<Upstream.ValueToTest>
        let upstream: Upstream
        public init(upstream: Upstream, _ shrink: @escaping (Upstream.ValueToTest) -> RoseTree<Upstream.ValueToTest>) {
            self.upstream = upstream
            self.shrink = shrink
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Upstream.ValueToTest> {
            let value = upstream.generateWithoutShrinking(size, &rng)
            return shrink(value)
        }
    }
}

extension Generator {
    func overrideRoseTree(_ shrink: @escaping (ValueToTest) -> RoseTree<ValueToTest>) -> Generators.OverrideRoseTree<Self> {
        Generators.OverrideRoseTree(upstream: self, shrink)
    }
}
