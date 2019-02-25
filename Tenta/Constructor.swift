//
// Created by Niil Öhlin on 2018-12-02.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public struct Constructor {
    public var size: Size
    public var rng: SeededRandomNumberGenerator

    /// Recommended initializer.
    public init(size: Size, rng: inout SeededRandomNumberGenerator) {
        self.size = size
        self.rng = rng
    }

    /// Only use this if you know what you are doing.
    public init(size: Size) {
        self.size = size
        self.rng = SeededRandomNumberGenerator(seed: UInt64.random(in: 0...UInt64.max))
    }
}
