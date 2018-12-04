//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator where ValueToTest == String {
    static var string: Generator<String> {
        return Generator.array(elementGenerator: Generator<Character>.char).map { characters -> String in
            String(characters)
        }
    }

    static var alphaNumeric: Generator<String> {
        return Generator<Character>.alphaNumeric.generateString()
    }
}

extension String: Generatable {
    public static var generator: Generator<String> {
        return Tenta.Generator<String>.string
    }

}
