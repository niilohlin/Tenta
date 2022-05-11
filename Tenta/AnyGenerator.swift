//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import XCTest

public enum Generators {
    static let maxFilterTries = 500
}

/**
   AnyGenerator is a wrapper for a function that generates a value with accompanying shrink values in a `RoseTree`
*/
public struct AnyGenerator<ValueToTest>: Generator {
    public let generateClosure: (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>

    public init(generate: @escaping (Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>) {
        self.generateClosure = generate
    }

    public func generate(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest> {
        generateClosure(size, &rng)
    }
}
