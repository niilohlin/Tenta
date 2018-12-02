//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public typealias Size = UInt

public struct Constructor {
    public var size: Size
    public var rng: SeededRandomNumberGenerator
    init(size: Size, rng: inout SeededRandomNumberGenerator) {
        self.size = size
        self.rng = rng
    }
}

/**
   Generator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct Generator<ValueToTest> {
    private let maxFilterTries = 500
    public let generate: (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>

    public init(generate: @escaping (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generate = generate
    }

    /// Construct a generator without any shrinking. Very simple to do and good for large structs and classes.
    public static func simple(generateValue: @escaping (inout Constructor) -> ValueToTest) -> Generator<ValueToTest> {
        return Generator { size, rng in
            var constructor = Constructor(size: size, rng: &rng)
            let value = generateValue(&constructor)
            return RoseTree<ValueToTest>(root: value)
        }
    }

    /// Generate a value without its shrink tree.
    public func generate(using constructor: inout Constructor) -> ValueToTest {
        return self.generate(constructor.size, &constructor.rng).root()
    }
}

public extension Generator {
    func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            self.generate(size, &rng).map(transform)
        }
    }

    @available(*, deprecated, message: "Does not work right now.")
    func flatMap<Transformed>(
            _ transform: @escaping (ValueToTest) -> Generator<Transformed>
    ) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            let roseTree = self.generate(size, &rng)

            let newRng = rng

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
     let even = Generator<Int>.int.filter { $0 % 2 == 0 }
     ```
     - Parameter predicate: The predicate for which the values must pass.
     - Returns: A new generator with values which holds for `predicate`
    */
    func filter(_ predicate: @escaping (ValueToTest) -> Bool) -> Generator<ValueToTest> {
        return Generator { size, rng in
            for retrySize in size..<(size.advanced(by: self.maxFilterTries)) {
                let rose = self.generate(retrySize, &rng)
                if let filteredRose = rose.filter(predicate) {
                    return filteredRose
                }
            }
            fatalError("Max filter retries. Try easing filter requirement or use a constructive approach")
        }
    }

    /// Create a generator that generate elements in `Sequence`
    static func element<SequenceType: Sequence>(from sequence: SequenceType) -> Generator<SequenceType.Element> {
        var array = [SequenceType.Element]()
        var iterator = sequence.makeIterator()
        return Generator<SequenceType.Element> { _, rng in
            if let nextElement = iterator.next() {
                array.append(nextElement)
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

    /// Create a generator which depend on the size.
    static func withSize<Type>(_ createGeneratorWithSize: @escaping (Size) -> Generator<Type>) -> Generator<Type> {
        return Generator<Type> { size, rng in
            createGeneratorWithSize(size).generate(size, &rng)
        }
    }

    func overrideRoseTree(_ shrink: @escaping (ValueToTest) -> RoseTree<ValueToTest>) -> Generator<ValueToTest> {
        return Generator { size, rng in
            let value = self.generateWithoutShrinking(size, &rng)
            return shrink(value)
        }
    }
}
