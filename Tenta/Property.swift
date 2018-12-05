//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

/**
 Contains everything needed to run and rerun a `runTest` without needing to invoke the XCTestCase
 */
public struct Property<Value> {
    let description: String
    let generator: Generator<Value>
    let predicate: (Value) throws -> Bool
    let seed: UInt64
    let numberOfTests: UInt

    public init(
            description: String = #function,
            generator: Generator<Value>,
            seed: UInt64,
            numberOfTests: UInt,
            predicate: @escaping (Value) throws -> Bool
    ) {
        self.description = description
        self.generator = generator
        self.predicate = predicate
        self.seed = seed
        self.numberOfTests = numberOfTests
    }
}

extension Property {
    func checkProperty() -> Value? {
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
                return failedValue
            }
        }
        return nil
    }
}
