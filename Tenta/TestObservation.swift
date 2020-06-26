//
// Created by Niil Öhlin on 2018-12-04.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public class TestObservation: NSObject, XCTestObservation {
    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    public func testCase(
            _ testCase: XCTestCase,
            didFailWithDescription description: String,
            inFile filePath: String?,
            atLine lineNumber: Int
    ) {
        TestCasePropertyConverter.shared.set(false, for: testCase)
    }
}

internal class TestCasePropertyConverter {
    typealias RerunProperty = () -> Void

    static var shared: TestCasePropertyConverter = {
        TestCasePropertyConverter()
    }()

    private var reruns = [XCTestCase: (rerun: RerunProperty, didPass: Bool)]()
    init() {

    }

    func set(_ rerunProperty: @escaping RerunProperty, for testCase: XCTestCase) {
        reruns[testCase] = (rerun: rerunProperty, didPass: true)
    }

    func set(_ pass: Bool, for testCase: XCTestCase) {
        if let property = rerun(for: testCase) {
            reruns[testCase] = (rerun: property, didPass: pass)
        }
    }

    func passStatus(for testCase: XCTestCase) -> Bool {
        reruns[testCase]?.didPass ?? true
    }

    func rerun(for testCase: XCTestCase) -> RerunProperty? {
        reruns[testCase]?.rerun
    }

    func convert<TestValue>(
            predicate: @escaping (TestValue) throws -> Void,
            toBoolPredicate: Void,
            from testCase: XCTestCase
    ) -> ((TestValue) -> Bool) { { (testValue: TestValue) -> Bool in
            self.set(true, for: testCase)
            do {
                try predicate(testValue)
            } catch {
                self.set(false, for: testCase)
            }
            return self.passStatus(for: testCase)
        }
    }
}
