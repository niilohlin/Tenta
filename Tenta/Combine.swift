//
// Created by Niil Öhlin on 2018-11-15.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public class Combiner {
    var size: Double
    var rng: SeededRandomNumberGenerator

    init(size: Double, rng: inout SeededRandomNumberGenerator) {
        self.size = size
        self.rng = rng
    }

    func generate<T>(generator: Generator<T>) -> RoseTree<T> {
        return generator.generate(size, &rng)
    }
}

public extension Generator {
    func combine<OtherValue, Transformed>(
            with other: Generator<OtherValue>,
            transform: @escaping (ValueToTest, OtherValue) -> Transformed) -> Generator<Transformed> {
        return Generator<Transformed> { size, rng in
            let firstRose = self.generate(size, &rng)
            let secondRose = other.generate(size, &rng)
            return firstRose.combine(with: secondRose, transform: transform)
        }
    }
}
