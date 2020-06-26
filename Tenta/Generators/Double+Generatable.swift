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

extension Float {
    func towards(source: Float, minimumDelta: Float = 0.01) -> [Float] {
        Double(self).towards(source: Double(source), minimumDelta: Double(minimumDelta)).map { Float($0) }
    }
}

public extension Generator where ValueToTest == Double {
    static var double: Generator<Double> {
        Generator<Double> { size, rng in
            let value = Double.random(in: -Double(size)...Double(size), using: &rng)
            return RoseTree<Double>(seed: value) { 0.0.towards(source: $0) }
        }
    }
}

extension Double: Generatable {
    public static var generator: Generator<Double> {
        Generator<Double>.double
    }
}

public extension Generator where ValueToTest == Float {
    static var float: Generator<Float> {
        Generator<Float> { size, rng in
            let value = Float.random(in: -Float(size)...Float(size), using: &rng)
            return RoseTree<Float>(seed: value) { Float(0.0).towards(source: $0) }
        }
    }
}

extension Float: Generatable {
    public static var generator: Generator<Float> {
        Generator<Float>.float
    }
}
