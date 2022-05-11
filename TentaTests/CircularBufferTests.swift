//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
@testable import Tenta
import XCTest

struct CircularBuffer<Value> {
    var input: Int
    var output: Int
    let size: Int
    var buffer: [Value?]

    init(size: Int) {
        input = 0
        output = 0
        self.size = size + 1
        buffer = [Value?](repeating: nil, count: size + 1)
    }

    mutating func put(value: Value) {
        buffer[input] = value
        input = (input + 1) % size
    }

    mutating func get() -> Value? {
        let answer = buffer[output]
        output = (output + 1) % size
        return answer
    }

    var numberOfValues: Int {
        (input - output + size) % size
    }
}

enum Transition {
    case put(Int)
    case get
}

class CircularBufferTests: XCTestCase {
    func testCircularBuffer() {
        var buffer = CircularBuffer<Int>(size: 5)
        buffer.put(value: 1)
        buffer.put(value: 2)
        XCTAssertEqual(buffer.numberOfValues, 2)
    }

    func testCircularBuffer_prop() {
        let transitionGenerator = Int?.generator.map { $0.map(Transition.put) ?? Transition.get }.eraseToAnyGenerator()
        let sizeGenerator = Int.generator.map { abs($0) + 1 }.eraseToAnyGenerator()

        testPropertyWithXCTest(
            sizeGenerator,
            transitionGenerator.generateMany().eraseToAnyGenerator()
        ) { (size: Int, transitions: [Transition]) in
            var buffer = CircularBuffer<Int>(size: abs(size))
            var model = [Int]()
            for transition in transitions {
                if case .put(let value) = transition {
                    if buffer.numberOfValues < buffer.size - 1 {
                        buffer.put(value: value)
                        model.append(value)
                    }
                } else if buffer.numberOfValues != 0 {
                    let result = buffer.get()
                    XCTAssertEqual(result, model.first)
                    model = Array(model.dropFirst())
                }
                XCTAssertGreaterThanOrEqual(buffer.numberOfValues, 0)
                XCTAssertEqual(buffer.numberOfValues, model.count)
            }
        }
    }
}
