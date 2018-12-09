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
        func put(into buffer: CircularBuffer<Int>) -> Generator<CircularBuffer<Int>> {
            return Int.generator.map { value in
                var buffer = buffer
                buffer.put(value: value)
                return buffer
            }
        }

        func get(from buffer: CircularBuffer<Int>) -> Generator<CircularBuffer<Int>> {
            return Generator<CircularBuffer<Int>> { _, _ in
                var buffer = buffer
                _ = buffer.get()
                return RoseTree(root: buffer)
            }
        }
//
//        let bufferGenerator = Generator<CircularBuffer<Int>> { size, rng in
//            let puttedGenerator = Int.generator.flatMap { bufferSize in
//                let buffer = CircularBuffer<Int>(size: abs(bufferSize) + 1)
//                return put(into: buffer)
//            }
//        }

        runWithXCTest { (_: Int) in
        }
    }
}
