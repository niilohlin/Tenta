import Foundation

extension Generators {

    public struct Combine<Upstream1: Generator, Upstream2: Generator, Transformed>: Generator {

        private let lhs: Upstream1
        private let rhs: Upstream2
        private let transform: (Upstream1.ValueToTest, Upstream2.ValueToTest) -> Transformed
        public init(lhs: Upstream1, rhs: Upstream2, transform: @escaping (Upstream1.ValueToTest, Upstream2.ValueToTest) -> Transformed) {
            self.lhs = lhs
            self.rhs = rhs
            self.transform = transform
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Transformed> {
            let firstRose = lhs.generate(size, &rng)
            let secondRose = rhs.generate(size, &rng)
            return firstRose.combine(with: secondRose, transform: transform)
        }
    }

    static func combine<G1: Generator, G2: Generator, Transformed>(
        _ firstGenerator: G1,
        _ secondGenerator: G2,
        transform: @escaping (G1.ValueToTest, G2.ValueToTest) -> Transformed
    ) -> Combine<G1, G2, Transformed> {
        Combine(lhs: firstGenerator, rhs: secondGenerator, transform: transform)
    }

    static func combine<G1: Generator, G2: Generator>(
        _ firstGenerator: G1,
        _ secondGenerator: G2
    ) -> Combine<G1, G2, (G1.ValueToTest, G2.ValueToTest)> {
        Combine(lhs: firstGenerator, rhs: secondGenerator, transform: { ($0, $1) })
    }
}

extension Generator {
    func combine<G: Generator, Transformed>(
        with other: G,
        transform: @escaping (ValueToTest, G.ValueToTest) -> Transformed) -> Generators.Combine<Self, G, Transformed> {
            Generators.combine(self, other, transform: transform)
        }

    func combine<G: Generator>(with other: G) -> Generators.Combine<Self, G, (Self.ValueToTest, G.ValueToTest)> {
        Generators.combine(self, other)
    }
}
