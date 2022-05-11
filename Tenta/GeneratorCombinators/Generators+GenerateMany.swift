import Foundation

extension Generators {

    public struct GenerateMany<Upstream: Generator>: Generator {

        private let upstream: Upstream
        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<[Upstream.ValueToTest]> {
            if size <= 0 {
                return RoseTree(root: [], forest: [])
            }
            let value = (0 ... Int(size)).map { _ in upstream.generate(size, &rng) }

            //            let resultingArray = value.map { $0.root() }
            //            return RoseTree<[TestValue]>(seed: resultingArray) { (parentArray: [TestValue]) in
            //                parentArray.shrink()
            //            }
            return RoseTree<[Upstream.ValueToTest]>.combine(forest: value).flatMap { array in
                RoseTree(seed: array) { (parentArray: [Upstream.ValueToTest]) in
                    parentArray.shrink()
                }
            }
        }
    }


    /**
     Generates arrays of type `TestValue` and shrinks towards `[]`.

     - Usage:
     ```
     let intGenerator: AnyGenerator<Int> = AnyGenerator<Int>.int
     testProperty(generator: AnyGenerator<Int>.array(elementGenerator: intGenerator)) { array in
     array.count >= 0
     }
     ```
     - Parameter elementGenerator: AnyGenerator used when generating the values of the array.
     - Returns: A generator that generates arrays.
     */
    static func generateMany<G: Generator>(elementGenerator: G) -> Generators.GenerateMany<G> {
        Generators.GenerateMany(upstream: elementGenerator)
    }
}

extension Generator {
    func generateMany() -> Generators.GenerateMany<Self> {
        Generators.generateMany(elementGenerator: self)
    }
}
