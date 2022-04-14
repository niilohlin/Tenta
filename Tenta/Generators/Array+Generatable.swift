//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator {
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
    static func array<TestValue>(
            elementGenerator: AnyGenerator<TestValue>) -> AnyGenerator<[TestValue]> {
        AnyGenerator<[TestValue]> { size, rng in
            if size <= 0 {
                return RoseTree(root: [], forest: [])
            }
            let value = (0 ... Int(size)).map { _ in elementGenerator.generate(size, &rng) }

//            let resultingArray = value.map { $0.root() }
//            return RoseTree<[TestValue]>(seed: resultingArray) { (parentArray: [TestValue]) in
//                parentArray.shrink()
//            }
            return RoseTree<[TestValue]>.combine(forest: value).flatMap { array in
                RoseTree(seed: array) { (parentArray: [TestValue]) in
                    parentArray.shrink()
                }
            }
        }
    }

    static func sequence<TestValue>(
            of elementGenerator: AnyGenerator<TestValue>) -> AnyGenerator<AnySequence<TestValue>> {
        AnyGenerator<AnySequence<TestValue>> { _, _ in
            fatalError("Not implemented yet")
        }
    }

    static func set<TestValue: Hashable>(
            of elementGenerator: AnyGenerator<TestValue>) -> AnyGenerator<Set<TestValue>> {
        elementGenerator.generateMany().map(Set.init)
    }

    func reduce<Result>(
            _ initialResult: Result,
            _ nextPartialResult: @escaping (Result, ValueToTest) -> Result
    ) -> AnyGenerator<Result> {
        generateMany().map { $0.reduce(initialResult, nextPartialResult) }
    }

    func generateMany() -> AnyGenerator<[ValueToTest]> {
        AnyGenerator<[ValueToTest]>.array(elementGenerator: self)
    }

    func generateManyNonEmpty() -> AnyGenerator<[ValueToTest]> {
        AnyGenerator<[ValueToTest]>
                .array(elementGenerator: self)
                .combine(with: self, transform: { [$1] + $0 })
                .overrideRoseTree { (nonEmptyArray: [ValueToTest]) -> RoseTree<[ValueToTest]> in
                    RoseTree<[ValueToTest]>(seed: nonEmptyArray) { (parentArray: [ValueToTest]) in
                        parentArray.shrink().filter { !$0.isEmpty }
                    }
                }
    }

    func generateMany(length: Int) -> AnyGenerator<[ValueToTest]> {
        precondition(length >= 0)
        return AnyGenerator<[ValueToTest]> { size, rng in
            if length <= 0 {
                return RoseTree(root: [], forest: [])
            }
            var value = [RoseTree<ValueToTest>]()
            for _ in 0 ..< length {
                value.append(self.generate(size, &rng))
            }
            return RoseTree<[Int]>.combine(forest: value)
        }
    }
}

public extension AnyGenerator where ValueToTest: Collection, ValueToTest.Element: Generatable {

    func nonEmpty() -> AnyGenerator<ValueToTest> {
        filter { !$0.isEmpty }
    }
}

extension Array: Generatable where Array.Element: Generatable {
    /// The default int generator. Generates `Arrays`s according to the `size` parameter.
    public static var generator: AnyGenerator<[Array.Element]> {
        let generator: AnyGenerator<Element> = Element.generator
        return Tenta.AnyGenerator<Any>.array(elementGenerator: generator)
    }
}

extension Set: Generatable where Set.Element: Generatable {
    public static var generator: AnyGenerator<Set<Set.Element>> {
        let generator: AnyGenerator<Element> = Element.generator
        return Tenta.AnyGenerator<Set.Element>.set(of: generator)
    }
}
