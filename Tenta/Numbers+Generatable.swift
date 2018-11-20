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
