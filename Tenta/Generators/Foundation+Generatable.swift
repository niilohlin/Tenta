//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator where ValueToTest == Data {
    static var data: Generator<Data> {
        return [UInt8].generator.map { Data($0) }
    }
}

extension Data: Generatable {
    public static var generator: Generator<Data> {
        return Tenta.Generator<Data>.data
    }
}
