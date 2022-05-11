//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == String {
    static var string: AnyGenerator<String> {
        Generators.char.eraseToAnyGenerator().generateString()

    }

    static var alphaNumeric: AnyGenerator<String> {
        AnyGenerator<Character>.alphaNumeric.generateString()
    }

    static var utf8: AnyGenerator<String> {
        AnyGenerator<Character>.utf8.generateString()
    }
}

extension String: Generatable {
    public static var generator: AnyGenerator<String> {
        Tenta.AnyGenerator<String>.string
    }
}
