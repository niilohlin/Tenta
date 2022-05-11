//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public typealias Size = UInt

public protocol Generator {
    associatedtype ValueToTest

    func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
}

extension Generator {

    /// Generate a value without its shrink tree.
    public func generateUsing(_ constructor: inout Constructor) -> ValueToTest {
        generate(constructor.size, &constructor.rng).root()
    }
}

public extension Generator {
    func eraseToAnyGenerator() -> AnyGenerator<ValueToTest> {
        AnyGenerator(generate: generate(_:_:))
    }
}

public enum Generators {
    static let maxFilterTries = 500
}

/**
   AnyGenerator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct AnyGenerator<ValueToTest>: Generator {
    public let generateClosure: (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>

    public init(generate: @escaping (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generateClosure = generate
    }

    public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
        generateClosure(size, &rng)
    }
}

public extension AnyGenerator {

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
        }.eraseToAnyGenerator()
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
