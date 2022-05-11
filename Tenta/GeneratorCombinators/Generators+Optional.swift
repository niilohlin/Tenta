import Foundation

extension Generators {

    public struct Optional<Upstream: Generator>: Generator {

        private let upstream: Upstream
        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Upstream.ValueToTest?> {
            let value = Bool.random(using: &rng)
            if value {
                return upstream.generate(size, &rng).map(Swift.Optional.init(_:))
            }
            return RoseTree(root: nil)
        }
    }
}

extension Generator {
    func optional() -> Generators.Optional<Self> {
        Generators.Optional(upstream: self)
    }
}
