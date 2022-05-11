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
            associatedValue(forKey: &seedKey) ?? UInt64.random(in: (UInt64.min...UInt64.max))
        }
        set {
            setAssociatedValue(newValue, forKey: &seedKey)
        }
    }
    var numberOfTests: UInt {
        get {
            associatedValue(forKey: &numberOfTestsKey) ?? 100
        }
        set {
            setAssociatedValue(newValue, forKey: &numberOfTestsKey)
        }
    }
}

public extension XCTestCase {

    @discardableResult
    func runProperty<Gen: Generator, TestValue>(
            _ property: Property<Gen, TestValue>,
            file: StaticString = #file,
            line: UInt = #line
    ) -> TestResult<TestValue> where Gen.ValueToTest == TestValue {
        let testResult = property.checkProperty()
        if case let .failed(_, shrunk, _) = testResult, !property.expectFailure {
            XCTFail("failed with value: \(shrunk), reproduce run with seed: \(seed)", file: file, line: line)
        } else if case TestResult.succeeded = testResult, property.expectFailure {
            XCTFail("expected property to fail, but succeeded, reproduce run with seed \(seed)", file: file, line: line)
        }
        return testResult
    }

    /**
     Run test with specified generator.
     */
    @discardableResult
    func testProperty<Gen: Generator, TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: Gen,
            expectFailure: Bool = false,
            predicate: @escaping (TestValue) throws -> Bool
    ) -> TestResult<TestValue> where Gen.ValueToTest == TestValue {
        let property = Property(
                description: "testDesc",
                generator: generator,
                seed: seed,
                numberOfTests: numberOfTests,
                expectFailure: expectFailure,
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
            expectFailure: Bool = false,
            _ predicate: @escaping (TestValue) -> Bool
    ) -> TestResult<TestValue> {
        testProperty(
                file: file,
                line: line,
                generator: TestValue.self.generator,
                expectFailure: expectFailure,
                predicate: predicate
        )
    }

    @discardableResult
    func testProperty<G: Generator, H: Generator>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: G,
            _ secondGenerator: H,
            expectFailure: Bool = false,
            predicate: @escaping (G.ValueToTest, H.ValueToTest) throws -> Bool
    ) -> TestResult<(G.ValueToTest, H.ValueToTest)> {
        let property = Property(
                description: "",
                generator: firstGenerator.combine(with: secondGenerator, transform: { ($0, $1) }),
                seed: seed,
                numberOfTests: numberOfTests,
                expectFailure: expectFailure,
                predicate: predicate
        )

        return runProperty(property, file: file, line: line)
    }

    @discardableResult
    func testProperty<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            expectFailure: Bool = false,
            _ predicate: @escaping (TestValue, OtherTestValue) -> Bool
    ) -> TestResult<(TestValue, OtherTestValue)> {
        testProperty(
                file: file,
                line: line,
                TestValue.self.generator,
                OtherTestValue.self.generator,
                expectFailure: expectFailure,
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
        testPropertyWithXCTest(file: file, line: line, generator: TestValue.generator, test: test)
    }

    @discardableResult
    func testPropertyWithXCTest<G: Generator>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: G,
            test: @escaping (G.ValueToTest) throws -> Void
    ) -> TestResult<G.ValueToTest> {
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
                expectFailure: false,
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
        testPropertyWithXCTest(file: file, line: line, TestValue.generator, OtherTestValue.generator, test: test)
    }

    @discardableResult
    func testPropertyWithXCTest<G: Generator, H: Generator>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: G,
            _ secondGenerator: H,
            test: @escaping (G.ValueToTest, H.ValueToTest) throws -> Void
    ) -> TestResult<(G.ValueToTest, H.ValueToTest)> {
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
                expectFailure: false,
                predicate: predicate
        )

        TestCasePropertyConverter.shared.set({ _ = property.checkProperty() }, for: self)

        return runProperty(property, file: file, line: line)
    }
}
