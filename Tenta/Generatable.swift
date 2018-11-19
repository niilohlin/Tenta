//
// Created by Niil Öhlin on 2018-11-14.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

/**
 Represents a type that has a default generator. Used alongside tests to make a shorthand for the default generator.
 */
public protocol Generatable {
    static var generator: Generator<Self> { get }
}

extension Int: Generatable {
    /// The default int generator. Generates `Int`s according to the `size` parameter.
    public static var generator: Generator<Int> {
        return Generator<Int>.int
    }
}

extension Array: Generatable where Array.Element: Generatable {
    /// The default int generator. Generates `Arrays`s according to the `size` parameter.
    public static var generator: Generator<[Array.Element]> {
        let generator: Generator<Element> = Element.generator
        return Tenta.Generator<Any>.array(elementGenerator: generator)
    }
}
