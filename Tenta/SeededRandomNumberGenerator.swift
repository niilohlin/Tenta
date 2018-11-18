//
// Created by Niil Öhlin on 2018-10-14.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public struct SeededRandomNumberGenerator: RandomNumberGenerator {
    public var seed: UInt64

    public init(seed: UInt64) {
        self.seed = seed
    }

    public mutating func next() -> UInt64 {
        seed = 6364136223846793005 &* seed &+ 1442695040888963407
        return seed
    }
}
