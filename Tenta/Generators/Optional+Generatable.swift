//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator {
    func optional() -> Generator<ValueToTest?> {
        combine(with: Bool.generator) { value, bool in
            bool ? value : nil
        }
    }
}

extension Optional: Generatable where Wrapped: Generatable {
    public static var generator: Generator<Wrapped?> {
        Wrapped.generator.optional()
    }
}
