//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

/**
 Contains everything needed to run and rerun a `testProperty` without needing to invoke the XCTestCase
 */
public struct Property<G: Generator, Value> where G.ValueToTest == Value {
    let description: String
    let generator: G
    let predicate: (Value) throws -> Bool
    let seed: UInt64
    let numberOfTests: UInt
    let expectFailure: Bool

    public init(
            description: String = #function,
            generator: G,
            seed: UInt64,
            numberOfTests: UInt,
            expectFailure: Bool,
            predicate: @escaping (Value) throws -> Bool
    ) {
        self.description = description
        self.generator = generator
        self.predicate = predicate
        self.seed = seed
        self.numberOfTests = numberOfTests
        self.expectFailure = expectFailure
    }
}

extension Property {
    func checkProperty() -> TestResult<Value> {
        var rng = SeededRandomNumberGenerator(seed: seed)

        func runPredicate(_ value: Value) -> Bool {
            do {
                return try predicate(value)
            } catch {
                return false
            }
        }
        for size in 0..<numberOfTests {
            let rose = generator.generate(size, &rng)
            if !runPredicate(rose.root()) {
                let failedValue = rose.shrink(predicate: runPredicate)
                return .failed(value: rose.root(), shrunkValue: failedValue, shrinks: 0)
            }
        }
        return .succeeded
    }
}
