//
// Created by Niil Öhlin on 2018-11-20.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator where ValueToTest == UInt8 {
    static var uInt8: Generator<UInt8> {
        Generator<UInt8>.withSize { size in
            Generator.element(from: (0...UInt8(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt8: Generatable {
    public static var generator: Generator<UInt8> {
        Generator<UInt8>.uInt8
    }
}

public extension Generator where ValueToTest == UInt16 {
    static var uInt16: Generator<UInt16> {
        Generator<UInt16>.withSize { size in
            Generator.element(from: (0...UInt16(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt16: Generatable {
    public static var generator: Generator<UInt16> {
        Generator<UInt16>.uInt16
    }
}

public extension Generator where ValueToTest == UInt32 {
    static var uInt32: Generator<UInt32> {
        Generator<UInt32>.withSize { size in
            Generator.element(from: (0...UInt32(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt32: Generatable {
    public static var generator: Generator<UInt32> {
        Generator<UInt32>.uInt32
    }
}

public extension Generator where ValueToTest == Int {
    /**
     Generates an `Int`s and shrinks towards 0.

     Usage:
     ```
     testProperty(generator: Generator<Int>.int) { int in int % 1 == 0 }
     ```
     - Returns: A generator that generates `Int`s.
     */
    static var int: Generator<Int> {
        Generator<Int> { size, rng in
            if size <= 0 {
                return RoseTree(root: 0, forest: [])
            }
            let range = -Int(size) ... Int(size)
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: value, forest: 0.shrinkFrom(source: value))

        }
    }

    func nonZero() -> Generator<Int> {
        filter { $0 != 0 }
    }

    func nonNegative() -> Generator<Int> {
        map(abs)
    }

    func positive() -> Generator<Int> {
        nonNegative().map { $0 + 1 }
    }
}

extension Int: Generatable {
    /// The default int generator. Generates `Int`s according to the `size` parameter.
    public static var generator: Generator<Int> {
        Generator<Int>.int
    }
}

public extension Generator where ValueToTest == Decimal {
    static var decimal: Generator<Decimal> {
        Generator<Generator<Decimal>>.element(from: [
            Int.generator.map { Decimal($0) },
            Double.generator.map { Decimal($0) }
            ]
        ).flatMap { $0 }
    }
}

extension Decimal: Generatable {
    public static var generator: Generator<Decimal> {
        Generator<Decimal>.decimal
    }
}
