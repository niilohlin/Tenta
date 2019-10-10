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
            return associatedValue(forKey: &seedKey) ?? UInt64.random(in: (UInt64.min...UInt64.max))
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

    @discardableResult
    func runProperty<TestValue>(
            _ property: Property<TestValue>,
            file: StaticString = #file,
            line: UInt = #line
    ) -> TestResult<TestValue> {
        let testResult = property.checkProperty()
        if case let .failed(_, shrunk, _) = testResult {
            XCTFail("failed with value: \(shrunk), reproduce run with seed: \(seed)", file: file, line: line)
        }
        return testResult
    }

    /**
     Run test with specified generator.
     */
    @discardableResult
    func testProperty<TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: Generator<TestValue>,
            predicate: @escaping (TestValue) throws -> Bool
    ) -> TestResult<TestValue> {
        let property = Property(
                description: "testDesc",
                generator: generator,
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        return runProperty(property, file: file, line: line)
    }

    /**
     Run a test with the default generator.
     */
    @discardableResult
    func testProperty<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue) -> Bool
    ) -> TestResult<TestValue> {
        return testProperty(
                file: file,
                line: line,
                generator: TestValue.self.generator,
                predicate: predicate
        )
    }

    @discardableResult
    func testProperty<TestValue, OtherTestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: Generator<TestValue>,
            _ secondGenerator: Generator<OtherTestValue>,
            predicate: @escaping (TestValue, OtherTestValue) throws -> Bool
    ) -> TestResult<(TestValue, OtherTestValue)> {
        let property = Property(
                description: "",
                generator: firstGenerator.combine(with: secondGenerator, transform: { ($0, $1) }),
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        return runProperty(property, file: file, line: line)
    }

    @discardableResult
    func testProperty<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue, OtherTestValue) -> Bool
    ) -> TestResult<(TestValue, OtherTestValue)> {
        return testProperty(
                file: file,
                line: line,
                TestValue.self.generator,
                OtherTestValue.self.generator,
                predicate: predicate
        )
    }
}

public extension XCTestCase {

    @discardableResult
    func testPropertyWithXCTest<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue) throws -> Void
    ) -> TestResult<TestValue> {
        return testPropertyWithXCTest(file: file, line: line, generator: TestValue.generator, test: test)
    }

    @discardableResult
    func testPropertyWithXCTest<TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: Generator<TestValue>,
            test: @escaping (TestValue) throws -> Void
    ) -> TestResult<TestValue> {
        let predicate = TestCasePropertyConverter.shared.convert(
                predicate: test,
                toBoolPredicate: (),
                from: self
        )

        let property = Property(
                description: "",
                generator: generator,
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        TestCasePropertyConverter.shared.set({ _ = property.checkProperty() }, for: self)

        return runProperty(property, file: file, line: line)
    }

    @discardableResult
    func testPropertyWithXCTest<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue, OtherTestValue) throws -> Void

    ) -> TestResult<(TestValue, OtherTestValue)> {
        return testPropertyWithXCTest(file: file, line: line, TestValue.generator, OtherTestValue.generator, test: test)
    }

    @discardableResult
    func testPropertyWithXCTest<TestValue, OtherTestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: Generator<TestValue>,
            _ secondGenerator: Generator<OtherTestValue>,
            test: @escaping (TestValue, OtherTestValue) throws -> Void
    ) -> TestResult<(TestValue, OtherTestValue)> {
        let predicate = TestCasePropertyConverter.shared.convert(
                predicate: test,
                toBoolPredicate: (),
                from: self
        )
        let property = Property(
                description: "",
                generator: firstGenerator.combine(with: secondGenerator),
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        TestCasePropertyConverter.shared.set({ _ = property.checkProperty() }, for: self)

        return runProperty(property, file: file, line: line)
    }
}
