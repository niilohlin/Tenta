//
// Created by Niil Öhlin on 2018-12-01.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

private var seedKey = false
private var numberOfTestsKey = false
public extension XCTestCase {
    var seed: UInt64 {
        get {
            return associatedValue(forKey: &seedKey) ?? 100
        }
        set {
            setAssociatedValue(newValue, forKey: &seedKey)
        }
    }
    var numberOfTests: UInt {
        get {
            return associatedValue(forKey: &numberOfTestsKey) ?? 100
        }
        set {
            setAssociatedValue(newValue, forKey: &numberOfTestsKey)
        }
    }
}

public extension XCTestCase {

    /**
     Placeholder function for running tests.
     */
    func runTest<TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            gen: Generator<TestValue>,
            predicate: @escaping (TestValue) throws -> Bool
    ) {
        var rng = SeededRandomNumberGenerator(seed: seed)

        func runPredicate(_ value: TestValue) -> Bool {
            do {
                return try predicate(value)
            } catch {
                return false
            }
        }

        for size in 0..<numberOfTests {
            let rose = gen.generate(size, &rng)
            if !runPredicate(rose.root()) {
                print("starting shrink")
                let failedValue = rose.shrink(predicate: runPredicate)
                XCTFail("failed with value: \(failedValue), rerun with seed: \(seed)", file: file, line: line)
                break
            }
        }
    }

    /**
     Run a test with the default generator.
     */
    func runTest<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue) -> Bool
    ) {
        runTest(
                file: file,
                line: line,
                gen: TestValue.self.generator,
                predicate: predicate
        )
    }

    func runTest<TestValue, OtherTestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: Generator<TestValue>,
            _ secondGenerator: Generator<OtherTestValue>,
            predicate: @escaping (TestValue, OtherTestValue) throws -> Bool
    ) {
        var rng = SeededRandomNumberGenerator(seed: seed)

        func runPredicate(_ value: TestValue, _ other: OtherTestValue) -> Bool {
            do {
                return try predicate(value, other)
            } catch {
                return false
            }
        }

        for size in 0..<numberOfTests {
            let rose = firstGenerator.combine(with: secondGenerator, transform: { ($0, $1) })
                .generate(size, &rng)
            let (firstValue, secondValue) = rose.root()

            if !runPredicate(firstValue, secondValue) {
                print("starting shrink")
                let failedValue = rose.shrink(predicate: runPredicate)
                XCTFail("failed with value: \(failedValue), rerun with seed: \(seed)", file: file, line: line)
                break
            }
        }
    }

    func runTest<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue, OtherTestValue) -> Bool
    ) {
        runTest(
                file: file,
                line: line,
                TestValue.self.generator,
                OtherTestValue.self.generator,
                predicate: predicate
        )
    }
}
