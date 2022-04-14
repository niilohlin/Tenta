//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public typealias Size = UInt

protocol Generator {
    associatedtype ValueToTest

    func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
}

/**
   AnyGenerator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct AnyGenerator<ValueToTest>: Generator {
    private let maxFilterTries = 500
    public let generateClosure: (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>

    public init(generate: @escaping (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generateClosure = generate
    }

    public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
        generateClosure(size, &rng)
    }

    public init(value: ValueToTest) {
        generateClosure = { _, _ in
            RoseTree<ValueToTest>(root: value)
        }
    }

    /// Construct a generator without any shrinking. Very simple to do and good for large structs and classes.
    public static func simple(generateValue: @escaping (inout Constructor) -> ValueToTest) -> AnyGenerator<ValueToTest> {
        AnyGenerator { size, rng in
            var constructor = Constructor(size: size, rng: &rng)
            let value = generateValue(&constructor)
            return RoseTree<ValueToTest>(root: value)
        }
    }

    /// Generate a value without its shrink tree.
    public func generateUsing(_ constructor: inout Constructor) -> ValueToTest {
        generate(constructor.size, &constructor.rng).root()
    }
}

public extension AnyGenerator {
    func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> AnyGenerator<Transformed> {
        AnyGenerator<Transformed> { size, rng in
            self.generate(size, &rng).map(transform)
        }
    }

    func flatMap<Transformed>(
            _ transform: @escaping (ValueToTest) -> AnyGenerator<Transformed>
    ) -> AnyGenerator<Transformed> {
        AnyGenerator<Transformed> { size, rng in
            let roseTree = self.generate(size, &rng)

            let newRng = rng.clone()

            return roseTree.flatMap { generatedValue in
                var newRng = newRng
                return transform(generatedValue).generate(size, &newRng)
            }
        }
    }

    /**
     Filters values from a generator.

     Usage:
     ```
     let even = AnyGenerator<Int>.int.filter { $0 % 2 == 0 }
     ```
     - Parameter predicate: The predicate for which the values must pass.
     - Returns: A new generator with values which holds for `predicate`
    */
    func filter(_ predicate: @escaping (ValueToTest) -> Bool) -> AnyGenerator<ValueToTest> {
        AnyGenerator { size, rng in
            for retrySize in size..<(size.advanced(by: self.maxFilterTries)) {
                let rose = self.generate(retrySize, &rng)
                if let filteredRose = rose.filter(predicate) {
                    return filteredRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }

    /**
     Transforms and filters a value if the transform returns `nil`

     Usage:
     ```
     let urlAnyGenerator = AnyGenerator<String>.compactMap(URL.init(string:))
     ```
     - Parameter transform: The transform to be applied.
     - Returns: A new generator that returns the transformed values, except for `nil`
     */
    func compactMap<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed?) -> AnyGenerator<Transformed> {
        AnyGenerator<Transformed> { size, rng in
            for retrySize in size..<(size.advanced(by: self.maxFilterTries)) {
                let rose = self.generate(retrySize, &rng)
                if let transformedRose = rose.compactMap(transform) {
                    return transformedRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }

    /// Create a generator that generate elements in `Sequence`
    static func element<SequenceType: Sequence>(from sequence: SequenceType) -> AnyGenerator<SequenceType.Element> {
        var array = [SequenceType.Element]()
        var iterator = sequence.makeIterator()
        return AnyGenerator<SequenceType.Element> { size, rng in
            for _ in 0..<(size + 1) {
                if let nextElement = iterator.next() {
                    array.append(nextElement)
                } else {
                    break
                }
            }
            guard let element = array.randomElement(using: &rng) else {
                fatalError("Could not generate an element from an empty sequence")
            }
            return RoseTree<SequenceType.Element>(
                    root: element,
                    forest: array.map { RoseTree(root: $0) }
            )
        }
    }

    static func chooseAnyGeneratorFrom<S: Sequence>(_ generators: S)
                    -> AnyGenerator<ValueToTest> where S.Iterator.Element == (Int, AnyGenerator<ValueToTest>) {
        let generators: [(Int, AnyGenerator<ValueToTest>)] = Array(generators)
        assert(!generators.isEmpty, "Cannot chose from an empty sequence")
        let generatorList = generators.flatMap { tuple in
            [AnyGenerator<ValueToTest>](repeating: tuple.1, count: tuple.0)
        }
        return Int.generator.nonNegative().flatMap { index in
            generatorList[index % generatorList.count]
        }
    }

    /// Create a generator which depend on the size.
    static func withSize<Type>(_ createAnyGeneratorWithSize: @escaping (Size) -> AnyGenerator<Type>) -> AnyGenerator<Type> {
        AnyGenerator<Type> { size, rng in
            createAnyGeneratorWithSize(size).generate(size, &rng)
        }
    }

    func overrideRoseTree(_ shrink: @escaping (ValueToTest) -> RoseTree<ValueToTest>) -> AnyGenerator<ValueToTest> {
        AnyGenerator { size, rng in
            let value = self.generateWithoutShrinking(size, &rng)
            return shrink(value)
        }
    }
}
