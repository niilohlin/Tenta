//
// Created by Niil Öhlin on 2018-11-20.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == UInt8 {
    static var uInt8: AnyGenerator<UInt8> {
        AnyGenerator<UInt8>.withSize { size in
            AnyGenerator.element(from: (0...UInt8(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt8: Generatable {
    public static var generator: AnyGenerator<UInt8> {
        AnyGenerator<UInt8>.uInt8
    }
}

public extension AnyGenerator where ValueToTest == UInt16 {
    static var uInt16: AnyGenerator<UInt16> {
        AnyGenerator<UInt16>.withSize { size in
            AnyGenerator.element(from: (0...UInt16(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt16: Generatable {
    public static var generator: AnyGenerator<UInt16> {
        AnyGenerator<UInt16>.uInt16
    }
}

public extension AnyGenerator where ValueToTest == UInt32 {
    static var uInt32: AnyGenerator<UInt32> {
        AnyGenerator<UInt32>.withSize { size in
            AnyGenerator.element(from: (0...UInt32(truncatingIfNeeded: Int(size))))
        }
    }
}

extension UInt32: Generatable {
    public static var generator: AnyGenerator<UInt32> {
        AnyGenerator<UInt32>.uInt32
    }
}

public extension AnyGenerator where ValueToTest == Int {
    /**
     Generates an `Int`s and shrinks towards 0.

     Usage:
     ```
     testProperty(generator: AnyGenerator<Int>.int) { int in int % 1 == 0 }
     ```
     - Returns: A generator that generates `Int`s.
     */
    static var int: AnyGenerator<Int> {
        AnyGenerator<Int> { size, rng in
            if size <= 0 {
                return RoseTree(root: 0, forest: [])
            }
            let range = -Int(size) ... Int(size)
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: value, forest: 0.shrinkFrom(source: value))

        }
    }

    func nonZero() -> AnyGenerator<Int> {
        filter { $0 != 0 }
    }

    func nonNegative() -> AnyGenerator<Int> {
        map(abs)
    }

    func positive() -> AnyGenerator<Int> {
        nonNegative().map { $0 + 1 }
    }
}

extension Int: Generatable {
    /// The default int generator. Generates `Int`s according to the `size` parameter.
    public static var generator: AnyGenerator<Int> {
        AnyGenerator<Int>.int
    }
}

public extension AnyGenerator where ValueToTest == Decimal {
    static var decimal: AnyGenerator<Decimal> {
        AnyGenerator<AnyGenerator<Decimal>>.element(from: [
            Int.generator.map { Decimal($0) },
            Double.generator.map { Decimal($0) }
            ]
        ).flatMap { $0 }
    }
}

extension Decimal: Generatable {
    public static var generator: AnyGenerator<Decimal> {
        AnyGenerator<Decimal>.decimal
    }
}
