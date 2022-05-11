import Foundation

extension Generators {
    public struct Filter<Upstream: Generator>: Generator {
        public var predicate: (Upstream.ValueToTest) -> Bool
        public var upstream: Upstream

        public init(upstream: Upstream, predicate: @escaping (Upstream.ValueToTest) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Upstream.ValueToTest> {
            for retrySize in size..<(size.advanced(by: Generators.maxFilterTries)) {
                let rose = upstream.generate(retrySize, &rng)
                if let filteredRose = rose.filter(predicate) {
                    return filteredRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }
}

extension Generator {
    /**
     Filters values from a generator.

     Usage:
     ```
     let even = AnyGenerator<Int>.int.filter { $0 % 2 == 0 }
     ```
     - Parameter predicate: The predicate for which the values must pass.
     - Returns: A new generator with values which holds for `predicate`
    */
    public func filter(_ predicate: @escaping (ValueToTest) -> Bool) -> Generators.Filter<Self> {
        Generators.Filter(upstream: self, predicate: predicate)
    }
}

extension Generators.Filter {
    public func filter(_ predicate: @escaping (ValueToTest) -> Bool) -> Generators.Filter<Upstream> {
        Generators.Filter(upstream: self.upstream, predicate: { x in self.predicate(x) && predicate(x) } )
    }
}
