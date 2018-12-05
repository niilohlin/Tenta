//
// Created by Niil Öhlin on 2018-12-05.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

protocol Testable {
    var isSuccessful: Bool { get }
}

extension Bool: Testable {
    var isSuccessful: Bool {
        return self
    }
}
