//
// Created by Niil Öhlin on 2018-11-19.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

extension Double {
    func towards(source: Double, minimumDelta: Double = 0.01) -> [Double] {
        let destination = self
        let x = source
        if abs(destination - x) < minimumDelta {
            return []
        }

        let diff = x - destination

        let sequence = AnySequence<Double> { () -> AnyIterator<Double> in
            var diff = diff
            return AnyIterator {
                let result: Double = diff
                guard result.isFinite && !result.isNaN && abs(result) > minimumDelta else {
                    return nil
                }
                diff /= 2
                return x - result
            }
        }
        return Array(sequence)
    }
}

public extension Generator where ValueToTest == Double {
    static var double: Generator<Double> {
        return Generator<Double> { size, rng in
            let value = Double.random(in: -size...size, using: &rng)
            return RoseTree<Double>(seed: value) { 0.0.towards(source: $0) }
        }
    }
}

extension Double: Generatable {
    public static var generator: Generator<Double> {
        return Generator<Double>.double
    }
}
