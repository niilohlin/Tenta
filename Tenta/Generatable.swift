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
