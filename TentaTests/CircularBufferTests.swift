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
        self.size = size
        buffer = [Value?](repeating: nil, count: size)
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
        return (input - output) % size
    }
}

enum BufferTransitions {
    case get
    case put(Int)
}
class CircularBufferTests: XCTestCase {
    func testCircularBuffer() {
        var buffer = CircularBuffer<Int>(size: 5)
        buffer.put(value: 1)
        buffer.put(value: 2)
        XCTAssertEqual(buffer.numberOfValues, 2)
    }

    func testCircularBuffer_prop() {
        let initializeBuffer = { () -> CircularBuffer<Int> in
             CircularBuffer<Int>(size: 5)
        }
        let transitionGenerator = Int?.generator.map { (maybeInt: Int?) -> BufferTransitions in
            if let int = maybeInt {
                return BufferTransitions.put(int)
            }
            return BufferTransitions.get
        }

        let bufferSFM = FiniteStateMachine<CircularBuffer<Int>, BufferTransitions>(
                initializeModel: initializeBuffer,
                transitions: transitionGenerator,
                precondition: { model, transition in
                    switch transition {
                    case .get:
                        return model.numberOfValues > 0
                    case .put:
                        return true
                    }
                },
                postcondition: { model, transition in
                    switch transition {
                    case .get:
                        return model.numberOfValues >= 0
                    case .put:
                        return model.numberOfValues > 0
                    }
                },
                runTransition: { model, transition in
                    var model = model
                    switch transition {
                    case .get:
                        model.get()
                        return model
                    case .put(let value):
                        model.put(value: value)
                        return model
                    }
                }
        )

//        let bufferGenerator = Generator<CircularBuffer> { size, rng in
//            let buffer = CircularBuffer(size: size + 1)
//
//
//        }

        runWithXCTest { (_: Int) in
        }
    }

}
