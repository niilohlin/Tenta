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

        let property = Property(
                description: "",
                generator: gen,
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        if let failedValue = property.checkProperty() {
            XCTFail("failed with value: \(failedValue), rerun with seed: \(seed)", file: file, line: line)
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

//        func unaryPredicate(tuple: (TestValue, OtherTestValue)) throws -> Bool {
//            return try predicate(tuple.0, tuple.1)
//        }

        let property = Property(
                description: "",
                generator: firstGenerator.combine(with: secondGenerator, transform: { ($0, $1) }),
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        if let failedValue = property.checkProperty() {
            XCTFail("failed with value: \(failedValue), rerun with seed: \(seed)", file: file, line: line)
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
