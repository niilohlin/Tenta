//
// Created by Niil Öhlin on 2018-11-15.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator {

    static func combine<FirstValue, SecondValue, ThirdValue, Transformed>(
        _ firstAnyGenerator: AnyGenerator<FirstValue>,
        _ secondAnyGenerator: AnyGenerator<SecondValue>,
        _ thirdAnyGenerator: AnyGenerator<ThirdValue>,
        transform: @escaping (FirstValue, SecondValue, ThirdValue) -> Transformed) -> AnyGenerator<Transformed> {
            AnyGenerator<Transformed> { size, rng in
                let firstRose = firstAnyGenerator.generate(size, &rng)
                let secondRose = secondAnyGenerator.generate(size, &rng)
                let thirdRose = thirdAnyGenerator.generate(size, &rng)
                return firstRose
                    .combine(with: secondRose, transform: { ($0, $1) })
                    .combine(with: thirdRose, transform: { transform($0.0, $0.1, $1) })
            }
        }

    static func combine<Value>(_ generators: [AnyGenerator<Value>]) -> AnyGenerator<[Value]> {
        AnyGenerator<[Value]> { size, rng in
            // Cannot use map because `rng` is inout
            var forest = [RoseTree<Value>]()
            for generator in generators {
                forest.append(generator.generate(size, &rng))
            }

            return RoseTree<Value>.combine(forest: forest)
        }
    }

    static func combine<Value, Transformed>(
        _ generators: [AnyGenerator<Value>],
        transform: @escaping ([Value]) -> Transformed
    ) -> AnyGenerator<Transformed> {
            AnyGenerator.combine(generators).map(transform).eraseToAnyGenerator()
    }
}
