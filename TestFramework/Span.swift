//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

struct Span<T> {
    let origin: T
    let span: (Double) -> (T, T)
}
