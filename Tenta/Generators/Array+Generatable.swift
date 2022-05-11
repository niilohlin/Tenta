//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator {
    static func sequence<TestValue>(
        of elementGenerator: AnyGenerator<TestValue>) -> AnyGenerator<AnySequence<TestValue>> {
            AnyGenerator<AnySequence<TestValue>> { _, _ in
                fatalError("Not implemented yet")
            }
        }

    static func set<TestValue: Hashable>(
        of elementGenerator: AnyGenerator<TestValue>) -> AnyGenerator<Set<TestValue>> {
            elementGenerator.generateMany().map(Set.init).eraseToAnyGenerator()
        }

    func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: @escaping (Result, ValueToTest) -> Result
    ) -> AnyGenerator<Result> {
        generateMany().map { $0.reduce(initialResult, nextPartialResult) }.eraseToAnyGenerator()
    }

    func generateManyNonEmpty() -> AnyGenerator<[ValueToTest]> {
        Generators
            .generateMany(elementGenerator: self).eraseToAnyGenerator()
            .combine(with: self, transform: { [$1] + $0 })
            .overrideRoseTree { (nonEmptyArray: [ValueToTest]) -> RoseTree<[ValueToTest]> in
                RoseTree<[ValueToTest]>(seed: nonEmptyArray) { (parentArray: [ValueToTest]) in
                    parentArray.shrink().filter { !$0.isEmpty }
                }
            }
            .eraseToAnyGenerator()
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

    func nonEmpty() -> Generators.Filter<AnyGenerator<ValueToTest>> {
        filter { !$0.isEmpty }
    }
}

extension Array: Generatable where Array.Element: Generatable {

    /// The default int generator. Generates `Arrays`s according to the `size` parameter.
    public static var generator: AnyGenerator<[Array.Element]> {
        let generator: AnyGenerator<Element> = Element.generator
        return Generators.generateMany(elementGenerator: generator).eraseToAnyGenerator()
    }
}

extension Set: Generatable where Set.Element: Generatable {
    public static var generator: AnyGenerator<Set<Set.Element>> {
        let generator: AnyGenerator<Element> = Element.generator
        return Tenta.AnyGenerator<Set.Element>.set(of: generator)
    }
}
