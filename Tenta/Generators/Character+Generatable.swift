//
// Created by Niil Öhlin on 2018-11-19.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == Character {

    static var utf8: AnyGenerator<Character> {
        AnyGenerator<UInt32>.uInt32.compactMap { int in
            Unicode.Scalar(int).map { Character($0) }
        }.eraseToAnyGenerator()
    }

    static var alphaNumeric: AnyGenerator<Character> {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        return Generators.element(from: alphabet + alphabet.uppercased() + "1234567890").eraseToAnyGenerator()
    }

    func generateString() -> AnyGenerator<String> {
        // Maybe use join instead?
        reduce("") { $0 + String($1) }.eraseToAnyGenerator()
    }
}

extension Character: Generatable {
    public static var generator: Generators.CharGenerator {
        Generators.char
    }
}
