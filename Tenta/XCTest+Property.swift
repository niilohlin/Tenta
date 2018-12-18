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

    @discardableResult
    func runProperty<TestValue>(
            _ property: Property<TestValue>,
            file: StaticString = #file,
            line: UInt = #line
    ) -> TestResult<TestValue> {
        let testResult = property.checkProperty()
        if case let .failed(_, shrunk, _) = testResult {
            XCTFail("failed with value: \(shrunk), rerun with seed: \(seed)", file: file, line: line)
        }
        return testResult
    }

    /**
     Run test with specified generator.
     */
    @discardableResult
    func runTest<TestValue>(
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
    func runTest<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue) -> Bool
    ) -> TestResult<TestValue> {
        return runTest(
                file: file,
                line: line,
                generator: TestValue.self.generator,
                predicate: predicate
        )
    }

    @discardableResult
    func runTest<TestValue, OtherTestValue>(
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
    func runTest<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            _ predicate: @escaping (TestValue, OtherTestValue) -> Bool
    ) -> TestResult<(TestValue, OtherTestValue)> {
        return runTest(
                file: file,
                line: line,
                TestValue.self.generator,
                OtherTestValue.self.generator,
                predicate: predicate
        )
    }
}

public extension XCTestCase {

    func runWithXCTest<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue) throws -> Void
    ) -> TestResult<TestValue> {
        return runWithXCTest(file: file, line: line, generator: TestValue.generator, test: test)
    }

    func runWithXCTest<TestValue>(
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

    func runWithXCTest<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue, OtherTestValue) throws -> Void

    ) -> TestResult<(TestValue, OtherTestValue)> {
        return runWithXCTest(file: file, line: line, TestValue.generator, OtherTestValue.generator, test: test)
    }

    func runWithXCTest<TestValue, OtherTestValue>(
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

public extension XCTestCase {
    func runStateMachine<StateMachineType: StateMachine>(
            of type: StateMachineType.Type,
            file: StaticString = #file,
            line: UInt = #line
    ) -> TestResult<[StateMachineType.Command]> {
        return runTest(file: file, line: line, generator: type.commands()) { (commands: [StateMachineType.Command]) in
            var state = StateMachineType.initialState
            for command in commands {
                state = type.nextState(state, command)
                if !type.postcondition(state, command) {
                    return false
                }
            }
            return true
        }
    }
}
