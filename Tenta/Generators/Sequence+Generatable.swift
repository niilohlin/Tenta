//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator {
    /**
     Generates arrays of type `TestValue` and shrinks towards `[]`.

     - Usage:
     ```
     let intGenerator: Generator<Int> = Generator<Int>.int
     runTest(generator: Generator<Int>.array(elementGenerator: intGenerator)) { array in
         array.count >= 0
     }
     ```
     - Parameter elementGenerator: Generator used when generating the values of the array.
     - Returns: A generator that generates arrays.
     */
    static func array<TestValue>(
            elementGenerator: Generator<TestValue>) -> Generator<[TestValue]> {
        return Generator<[TestValue]> { size, rng in
            if size <= 0 {
                return RoseTree(root: [], forest: [])
            }
            var value = [RoseTree<TestValue>]()
            for _ in 0 ... Int(size) {
                value.append(elementGenerator.generate(size, &rng))
            }
//            let resultingArray = value.map { $0.root() }
//            return RoseTree<[TestValue]>(seed: resultingArray) { (parentArray: [TestValue]) in
//                parentArray.shrink()
//            }
            return RoseTree<[Int]>.combine(forest: value).flatMap { array in
                RoseTree(seed: array) { (parentArray: [TestValue]) in
                    parentArray.shrink()
                }
            }
        }
    }

    static func sequence<TestValue>(
            of elementGenerator: Generator<TestValue>) -> Generator<AnySequence<TestValue>> {
        return Generator<AnySequence<TestValue>> { _, _ in
            fatalError("Not implemented yet")
        }
    }

    static func set<TestValue: Hashable>(
            of elementGenerator: Generator<TestValue>) -> Generator<Set<TestValue>> {
        return elementGenerator.generateMany().map(Set.init)
    }

    func reduce<Result>(
            _ initialResult: Result,
            _ nextPartialResult: @escaping (Result, ValueToTest) -> Result
    ) -> Generator<Result> {
        return generateMany().map { $0.reduce(initialResult, nextPartialResult) }
    }

    func generateMany() -> Generator<[ValueToTest]> {
        return Generator<[ValueToTest]>.array(elementGenerator: self)
    }

    func generateManyNonEmpty() -> Generator<[ValueToTest]> {
        return Generator<[ValueToTest]>
                .array(elementGenerator: self)
                .combine(with: self, transform: { [$1] + $0 })
                .overrideRoseTree { (nonEmptyArray: [ValueToTest]) -> RoseTree<[ValueToTest]> in
                    RoseTree<[ValueToTest]>(seed: nonEmptyArray) { (parentArray: [ValueToTest]) in
                        parentArray.shrink().filter { !$0.isEmpty }
                    }
                }
    }
}

public extension Generator where ValueToTest: Collection, ValueToTest.Element: Generatable {

    func nonEmpty() -> Generator<ValueToTest> {
        return filter { !$0.isEmpty }
    }
}

extension Array: Generatable where Array.Element: Generatable {
    /// The default int generator. Generates `Arrays`s according to the `size` parameter.
    public static var generator: Generator<[Array.Element]> {
        let generator: Generator<Element> = Element.generator
        return Tenta.Generator<Any>.array(elementGenerator: generator)
    }
}

extension Set: Generatable where Set.Element: Generatable {
    public static var generator: Generator<Set<Set.Element>> {
        let generator: Generator<Element> = Element.generator
        return Tenta.Generator<Set.Element>.set(of: generator)
    }
}
