//
// Created by Niil Öhlin on 2018-12-10.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public struct ModifyingGenerator<ValueToTest> {
    public let modify: (inout ValueToTest, Size, inout SeededRandomNumberGenerator) -> RoseTree<ValueToTest>
}

