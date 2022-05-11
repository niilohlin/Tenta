import Foundation

extension Generators {
    public struct CompactMap<Upstream: Generator, ValueToTest>: Generator {
        public var transform: (Upstream.ValueToTest) -> ValueToTest?
        public var upstream: Upstream

        public init(upstream: Upstream, transform: @escaping (Upstream.ValueToTest) -> ValueToTest?) {
            self.upstream = upstream
            self.transform = transform
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
            for retrySize in size..<(size.advanced(by: Generators.maxFilterTries)) {
                let rose = upstream.generate(retrySize, &rng)
                if let transformedRose = rose.compactMap(transform) {
                    return transformedRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }
}

extension Generator {
    /**
     Transforms and filters a value if the transform returns `nil`

     Usage:
     ```
     let urlAnyGenerator = AnyGenerator<String>.compactMap(URL.init(string:))
     ```
     - Parameter transform: The transform to be applied.
     - Returns: A new generator that returns the transformed values, except for `nil`
     */
    public func compactMap<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed?) -> Generators.CompactMap<Self, Transformed> {
        Generators.CompactMap(upstream: self, transform: transform)
    }
}

extension Generators.CompactMap {
    public func compactMap<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed?) -> Generators.CompactMap<Upstream, Transformed> {
        Generators.CompactMap(upstream: upstream, transform: { x in self.transform(x).flatMap(transform) })
    }
}
