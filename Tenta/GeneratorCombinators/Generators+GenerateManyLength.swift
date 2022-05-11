import Foundation

extension Generators {

    public struct GenerateManyLength<Upstream: Generator>: Generator {

        private let upstream: Upstream
        private let length: Int
        public init(upstream: Upstream, length: Int) {
            self.upstream = upstream
            self.length = length
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<[Upstream.ValueToTest]> {
            precondition(length >= 0)
            if length <= 0 {
                return RoseTree(root: [], forest: [])
            }
            var value = [RoseTree<Upstream.ValueToTest>]()
            for _ in 0 ..< length {
                value.append(upstream.generate(size, &rng))
            }
            return RoseTree<[Int]>.combine(forest: value)
        }
    }

    static func generateMany<G: Generator>(elementGenerator: G, length: Int) -> Generators.GenerateManyLength<G> {
        Generators.GenerateManyLength(upstream: elementGenerator, length: length)
    }
}

extension Generator {
    func generateMany(length: Int) -> Generators.GenerateManyLength<Self> {
        Generators.generateMany(elementGenerator: self, length: length)
    }
}
