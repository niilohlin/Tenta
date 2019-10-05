//
// Created by Niil Öhlin on 2018-12-20.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public struct Reporter<TestValue> {
    let report: (TestResult<TestValue>) -> Void
}

public extension Reporter {
    static var xcTestReporter: Reporter<TestValue> {
        return Reporter { result in
            switch result.type {
            case .succeeded:
                print("success")
            case .failed(value: _, shrunkValue: let value, shrinks: _):
                XCTFail(
                        "failed with value: \(value), rerun with seed: \(result.seed)",
                        file: result.file,
                        line: result.line
                )
            }
        }
    }
}
