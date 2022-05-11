//
// Created by Niil Öhlin on 2018-11-14.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

/**
 Represents a type that has a default generator. Used alongside tests to make a shorthand for the default generator.
 */
public protocol Generatable {
    associatedtype SelfGenerator: Generator where SelfGenerator.ValueToTest == Self
    static var generator: SelfGenerator { get }
}

extension Generatable {

    /// Generate a value without its shrink tree.
    public static func generate(using constructor: inout Constructor) -> Self {
        generator.generate(constructor.size, &constructor.rng).root()
    }

    /// Discouraged generator. Has side effects and are not reproducable
    public static func generate(size: Size = 10) -> Self {
        var constructor = Constructor(size: size)
        return generate(using: &constructor)
    }
}
