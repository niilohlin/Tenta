//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator {
    func optional() -> AnyGenerator<ValueToTest?> {
        combine(with: Bool.generator) { value, bool in
            bool ? value : nil
        }
    }
}

extension Optional: Generatable where Wrapped: Generatable {
    public static var generator: AnyGenerator<Wrapped?> {
        Wrapped.generator.optional()
    }
}
