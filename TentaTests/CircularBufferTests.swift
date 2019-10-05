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
        return (input - output + size) % size
    }
}

enum Transition {
    case put(Int)
    case get
}

struct BufferState {
    static var initialState: (CircularBuffer<Int>, [Int]) {
        return (CircularBuffer<Int>(size: 5), [])
    }

    static var command: Generator<Transition> {
        return Int?.generator.map {
            if let value = $0 {
                return Transition.put(value)
            }
            return Transition.get
        }
    }

    static func precondition(_ state: (CircularBuffer<Int>, [Int]), _ transition: Transition) -> Bool {
        switch transition {
        case .put:
            return state.1.count < 5
        case .get:
            return !state.1.isEmpty
        }
    }

    static func postcondition(_ state: (CircularBuffer<Int>, [Int]), _ transition: Transition) -> Bool {
        switch transition {
        case .put:
            return state.0.numberOfValues == state.1.count
        case .get:
            return state.0.numberOfValues == state.1.count
        }
    }

    static func nextState(
            _ state: (CircularBuffer<Int>, [Int]),
            _ command: Transition
    ) -> (CircularBuffer<Int>, [Int] ) {
        var (buffer, model) = state
        switch command {
        case .put(let value):
            buffer.put(value: value)
            return (buffer, model + [value])
        case .get:
            _ = buffer.get()
            return (buffer, Array(model.dropFirst()))
        }

    }
}

class CircularBufferTests: XCTestCase {
    func testCircularBuffer() {
        var buffer = CircularBuffer<Int>(size: 5)
        buffer.put(value: 1)
        buffer.put(value: 2)
        XCTAssertEqual(buffer.numberOfValues, 2)
    }

    func testCircularBuffer_prop() {
        let transitionGenerator = Int?.generator.map { $0.map(Transition.put) ?? Transition.get }
        let sizeGenerator = Int.generator.map { abs($0) + 1 }

        runWithXCTest(sizeGenerator, transitionGenerator.generateMany()) { (size: Int, transitions: [Transition]) in
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
