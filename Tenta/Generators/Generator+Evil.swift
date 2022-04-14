//
// Created by Niil Öhlin on 2018-12-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

#if !SWIFT_PACKAGE
import Foundation

class DummyClass {
}

public extension AnyGenerator where ValueToTest == String {
    static func evil() -> AnyGenerator<String> {
        guard let path = Bundle(for: DummyClass.self).path(forResource: "evil-strings", ofType: "txt") else {
            fatalError("could not find evil strings file")
        }

        let evilStrings: [String]
        do {
            let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let allStrings = content.components(separatedBy: CharacterSet.newlines)

            evilStrings = allStrings.filter { !$0.hasPrefix("#") }

        } catch {
            fatalError("could not load strings")
        }
        return AnyGenerator.element(from: evilStrings)
    }
}

#endif
