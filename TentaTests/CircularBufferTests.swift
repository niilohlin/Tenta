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

enum Transition {
    case put(Int)
    case get
}

struct BufferState: StateMachine {
    static var initialState: [Int] {
        return []
    }

    static var command: Generator<Transition> {
        return Int?.generator.map {
            if let value = $0 {
                return Transition.put(value)
            }
            return Transition.get
        }
    }

    static func precondition(_ state: [Int], _ transition: Transition) -> Bool {
        switch transition {
        case .put:
            return true
        case .get:
            return !state.isEmpty
        }
    }

    static func postcondition(_ state: [Int], _ transition: Transition) -> Bool {
        switch transition {
        case .put:
            return !state.isEmpty
        case .get:
            return true
        }
    }

    static func nextState(_ state: [Int], _ command: Transition) -> [Int] {
        switch command {
        case .put(let value):
            return state + [value]
        case .get:
            return Array(state.dropFirst())
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

    func example_testCircularBuffer_prop() {
        let transitionGenerator = Int?.generator.map { maybeValue -> Transition in
            if let value = maybeValue {
                return Transition.put(value)
            }
            return Transition.get
        }
        let sizeGenerator = Int.generator.map { abs($0) + 1 }

        runWithXCTest(sizeGenerator, transitionGenerator.generateMany()) { (size: Int, transitions: [Transition]) in
            var buffer = CircularBuffer<Int>(size: abs(size))
            for transition in transitions {
                if case .put(let value) = transition {
                    buffer.put(value: value)
                } else if buffer.numberOfValues != 0 {
                    _ = buffer.get()
                }
                XCTAssertGreaterThanOrEqual(buffer.numberOfValues, 0)
            }
        }
    }

    func testStateMachine() {
    }
}
