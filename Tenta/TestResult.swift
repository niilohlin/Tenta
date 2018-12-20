//
// Created by Niil Öhlin on 2018-12-18.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public struct TestResult<TestedType> {
    public enum ResultType<TestedType> {
        case succeeded
        case failed(
                value: TestedType,
                shrunkValue: TestedType,
                shrinks: Int,
                file: StaticString,
                line: UInt
        )
    }
    let type: ResultType<TestedType>
    let seed: UInt64
    let numberOfTests: UInt
}
