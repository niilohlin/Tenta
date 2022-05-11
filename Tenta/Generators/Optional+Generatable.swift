//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

extension Optional: Generatable where Wrapped: Generatable {
    public static var generator: AnyGenerator<Wrapped?> {
        Wrapped.generator.optional().eraseToAnyGenerator()
    }
}
