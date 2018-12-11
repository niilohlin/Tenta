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

    func runProperty<TestValue>(_ property: Property<TestValue>, file: StaticString = #file, line: UInt = #line) {
        if let failedValue = property.checkProperty() {
            XCTFail("failed with value: \(failedValue), rerun with seed: \(seed)", file: file, line: line)
        }
    }

    /**
     Run test with specified generator.
     */
    func runTest<TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: Generator<TestValue>,
            predicate: @escaping (TestValue) throws -> Bool
    ) {

        let property = Property(
                description: "testDesc",
                generator: generator,
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        runProperty(property, file: file, line: line)
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
                generator: TestValue.self.generator,
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
        let property = Property(
                description: "",
                generator: firstGenerator.combine(with: secondGenerator, transform: { ($0, $1) }),
                seed: seed,
                numberOfTests: numberOfTests,
                predicate: predicate
        )

        runProperty(property, file: file, line: line)
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

public extension XCTestCase {

    func runWithXCTest<TestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue) throws -> Void
    ) {
        runWithXCTest(file: file, line: line, generator: TestValue.generator, test: test)
    }

    func runWithXCTest<TestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            generator: Generator<TestValue>,
            test: @escaping (TestValue) throws -> Void
    ) {
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

        runProperty(property, file: file, line: line)
    }

    func runWithXCTest<TestValue: Generatable, OtherTestValue: Generatable>(
            file: StaticString = #file,
            line: UInt = #line,
            test: @escaping (TestValue, OtherTestValue) throws -> Void

    ) {
        runWithXCTest(file: file, line: line, TestValue.generator, OtherTestValue.generator, test: test)
    }

    func runWithXCTest<TestValue, OtherTestValue>(
            file: StaticString = #file,
            line: UInt = #line,
            _ firstGenerator: Generator<TestValue>,
            _ secondGenerator: Generator<OtherTestValue>,
            test: @escaping (TestValue, OtherTestValue) throws -> Void
    ) {
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

        runProperty(property, file: file, line: line)
    }
}

public extension XCTestCase {
    func runStateMachine<StateMachineType: StateMachine>(
            of type: StateMachineType.Type,
            file: StaticString = #file,
            line: UInt = #line
    ) {
        runTest(file: file, line: line, generator: type.commands()) { (commands: [StateMachineType.Command]) in
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
