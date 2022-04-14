//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == Bool {
    static var bool: AnyGenerator<Bool> {
        AnyGenerator<Bool> { _, rng in
            let value = Bool.random(using: &rng)
            return RoseTree<Bool>(
                    root: value,
                    forest: [false, true].map { bool in RoseTree(root: bool) }
            )
        }
    }
}

extension Bool: Generatable {
    public static var generator: AnyGenerator<Bool> {
        AnyGenerator<Bool>.bool
    }
}
