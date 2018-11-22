//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public typealias Size = Double

/**
   Generator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct Generator<ValueToTest> {
    private let maxFilterTries = 500
    public let generate: (Double, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
    public init(generate: @escaping (Double, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generate = generate
    }
}

public extension Generator {
    func map<Transformed>(_ transform: @escaping (ValueToTest) -> Transformed) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            self.generate(size, &rng).map(transform)
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
            for retrySize in Int(size)..<(Int(size) + self.maxFilterTries) {
                let rose = self.generate(Double(retrySize), &rng)
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
            return RoseTree<SequenceType.Element>(root: { element }, forest: { () -> [RoseTree<SequenceType.Element>] in
                array.map { elementInGeneratedSequence in RoseTree(root: { elementInGeneratedSequence }) }
            })
        }
    }

    /// Create a generator which depend on the size.
    static func withSize<Type>(_ createGeneratorWithSize: @escaping (Size) -> Generator<Type>) -> Generator<Type> {
        return Generator<Type> { size, rng in
            createGeneratorWithSize(size).generate(size, &rng)
        }
    }
}

public extension Generator where ValueToTest == Int {
    /**
     Generates an `Int`s and shrinks towards 0.

     Usage:
     ```
     runTest(Generator<Int>.int) { int in int % 1 == 0 }
     ```
     - Returns: A generator that generates `Int`s.
     */
    static var int: Generator<Int> {
        return Generator<Int> { size, rng in
            if size <= 0 {
                return RoseTree(root: { 0 }, forest: { [] })
            }
            let range = Int(-size)...Int(size)
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: { value }, forest: {
                0.shrinkFrom(source: value)
            })

        }
    }
}

public extension Generator {
    /**
     Generates arrays of type `TestValue` and shrinks towards `[]`.

     - Usage:
     ```
     let intGenerator: Generator<Int> = Generator<Int>.int
     runTest(gen: Generator<Int>.array(elementGenerator: intGenerator)) { array in
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
                return RoseTree(root: { [] }, forest: { [] })
            }
            var value = [RoseTree<TestValue>]()
            for _ in 0 ... Int(size) {
                value.append(elementGenerator.generate(size, &rng))
            }
            let resultingArray = value.map { $0.root() }
            return RoseTree<[TestValue]>(seed: resultingArray) { (parentArray: [TestValue]) in
                parentArray.shrink()
            }
//            return RoseTree<[Int]>.combine(forest: value).flatMap { array in
//                RoseTree(seed: array) { (parentArray: [TestValue]) in
//                    parentArray.shrink()
//                }
//            }
        }
    }
}

/**
 Placeholder function for running tests.
 */
public func runTest<TestValue>(
        gen: Generator<TestValue>, predicate: @escaping (TestValue) -> Bool) {
    var rng = SeededRandomNumberGenerator(seed: 100)

    for size in 0..<100 {
        let rose = gen.generate(Double(size), &rng)
        if !predicate(rose.root()) {
//            print("failed with tree: \(rose.description)")
            print("failed with value: \(rose.root())")
            //print("failed with rose: \(rose)")
            print("starting shrink")
            let failedValue = rose.shrink(predicate: predicate)
            print("failed with value: \(failedValue)")
            break
        }
    }
}

/**
 Run a test with the default generator.
 */
public func runTest<TestValue: Generatable>(_ predicate: @escaping (TestValue) -> Bool) {
    runTest(gen: TestValue.self.generator, predicate: predicate)
}
