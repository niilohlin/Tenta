import Foundation

extension Generators {

    public struct Reduce<Upstream: Generator, Result>: Generator {

        private let upstream: Upstream
        private let nextPartialResult: (Result, Upstream.ValueToTest) -> Result
        private let initialResult: Result
        public init(upstream: Upstream, initialResult: Result, nextPartialResult: @escaping (Result, Upstream.ValueToTest) -> Result) {
            self.upstream = upstream
            self.initialResult = initialResult
            self.nextPartialResult = nextPartialResult
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<Result> {
            upstream.generateMany().map { $0.reduce(initialResult, nextPartialResult) }.generate(size, &rng)
        }
    }
}

extension Generator {
    func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: @escaping (Result, ValueToTest) -> Result
    ) -> Generators.Reduce<Self, Result> {
        Generators.Reduce(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
    }
}

