//
// Created by Niil Öhlin on 2018-11-15.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator {
    func combine<OtherValue, Transformed>(
            with other: Generator<OtherValue>,
            transform: @escaping (ValueToTest, OtherValue) -> Transformed) -> Generator<Transformed> {
        Generator<Transformed>.combine(self, other, transform: transform)
    }

    func combine<OtherValue>(with other: Generator<OtherValue>) -> Generator<(ValueToTest, OtherValue)> {
        Generator<(ValueToTest, OtherValue)>.combine(self, other)
    }

    static func combine<FirstValue, SecondValue, Transformed>(
            _ firstGenerator: Generator<FirstValue>,
            _ secondGenerator: Generator<SecondValue>,
            transform: @escaping (FirstValue, SecondValue) -> Transformed) -> Generator<Transformed> {
        Generator<Transformed> { size, rng in
            let firstRose = firstGenerator.generate(size, &rng)
            let secondRose = secondGenerator.generate(size, &rng)
            return firstRose.combine(with: secondRose, transform: transform)
        }
    }

    static func combine<FirstValue, SecondValue>(
            _ firstGenerator: Generator<FirstValue>,
            _ secondGenerator: Generator<SecondValue>
            ) -> Generator<(FirstValue, SecondValue)> {
        Generator<(FirstValue, SecondValue)> { size, rng in
            let firstRose = firstGenerator.generate(size, &rng)
            let secondRose = secondGenerator.generate(size, &rng)
            return firstRose.combine(with: secondRose, transform: { ($0, $1) })
        }
    }

    static func combine<FirstValue, SecondValue, ThirdValue, Transformed>(
            _ firstGenerator: Generator<FirstValue>,
            _ secondGenerator: Generator<SecondValue>,
            _ thirdGenerator: Generator<ThirdValue>,
            transform: @escaping (FirstValue, SecondValue, ThirdValue) -> Transformed) -> Generator<Transformed> {
        Generator<Transformed> { size, rng in
            let firstRose = firstGenerator.generate(size, &rng)
            let secondRose = secondGenerator.generate(size, &rng)
            let thirdRose = thirdGenerator.generate(size, &rng)
            return firstRose
                    .combine(with: secondRose, transform: { ($0, $1) })
                    .combine(with: thirdRose, transform: { transform($0.0, $0.1, $1) })
        }
    }

    static func combine<Value>(_ generators: [Generator<Value>]) -> Generator<[Value]> {
        Generator<[Value]> { size, rng in
            // Cannot use map because `rng` is inout
            var forest = [RoseTree<Value>]()
            for generator in generators {
                forest.append(generator.generate(size, &rng))
            }

            return RoseTree<Value>.combine(forest: forest)
        }
    }

    static func combine<Value, Transformed>(
            _ generators: [Generator<Value>],
            transform: @escaping ([Value]) -> Transformed) -> Generator<Transformed> {
        Generator.combine(generators).map(transform)
    }

    /// Should only be used when combining large structs or classes.
    func generateWithoutShrinking(_ size: Size, _ rng: inout SeededRandomNumberGenerator) -> ValueToTest {
        generate(size, &rng).root()
    }
}
