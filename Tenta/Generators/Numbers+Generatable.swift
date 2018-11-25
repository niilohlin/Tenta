//
// Created by Niil Öhlin on 2018-11-20.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator where ValueToTest == UInt8 {
    static var uInt8: Generator<UInt8> {
        return Generator<UInt8>.withSize { size in
            Generator.element(from: (0...UInt8(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt8: Generatable {
    public static var generator: Generator<UInt8> {
        return Generator<UInt8>.uInt8
    }
}

public extension Generator where ValueToTest == Int {
    /**
     Generates an `Int`s and shrinks towards 0.

     Usage:
     ```
     runTest(Generator<Int>.int) { int in int % 1 == 0 }
     ```
     - Returns: A generator that generates `Int`s.
     */
    static var int: Generator<Int> {
        return Generator<Int> { size, rng in
            if size <= 0 {
                return RoseTree(root: { 0 }, forest: { [] })
            }
            let range = Int(-size)...Int(size)
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: { value }, forest: {
                0.shrinkFrom(source: value)
            })

        }
    }
}

extension Int: Generatable {
    /// The default int generator. Generates `Int`s according to the `size` parameter.
    public static var generator: Generator<Int> {
        return Generator<Int>.int
    }
}