//
// Created by Niil Öhlin on 2018-11-19.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == Character {
    static var char: AnyGenerator<Character> {
        AnyGenerator<UInt8>.element(from: 32...255).map { uInt8 in
            Character(UnicodeScalar(uInt8))
        }
    }

    static var utf8: AnyGenerator<Character> {
        AnyGenerator<UInt32>.uInt32.compactMap { int in
            Unicode.Scalar(int).map { Character($0) }
        }
    }

    static var alphaNumeric: AnyGenerator<Character> {
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        return AnyGenerator<Character>.element(from: alphabet + alphabet.uppercased() + "1234567890")
    }

    func generateString() -> AnyGenerator<String> {
        reduce("") { $0 + String($1) }
    }
}

extension Character: Generatable {
    public static var generator: AnyGenerator<Character> {
        AnyGenerator<Character>.char
    }
}
