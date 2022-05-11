import Foundation

extension Generators {

    public struct ChooseAnyGeneratorFrom<SequenceType: Sequence, G: Generator>: Generator
                                                                                where SequenceType.Element == (Int, G) {

        private let generators: SequenceType
        public init(generators: SequenceType) {
            self.generators = generators
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<G.ValueToTest> {
            let generators: [(Int, G)] = Array(generators)
            assert(!generators.isEmpty, "Cannot chose from an empty sequence")
            let generatorList = generators.flatMap { tuple in
                [G](repeating: tuple.1, count: tuple.0)
            }
            return Int.generator.nonNegative().flatMap { index in
                generatorList[index % generatorList.count]
            }.eraseToAnyGenerator().generate(size, &rng)
        }
    }

    static func chooseAnyGeneratorFrom<S: Sequence, G: Generator>(_ generators: S)
                                                -> ChooseAnyGeneratorFrom<S, G> where S.Iterator.Element == (Int, G) {
        ChooseAnyGeneratorFrom(generators: generators)
    }
}
