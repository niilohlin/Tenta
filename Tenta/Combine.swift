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

//public extension Generator {
//    static func combine<T>(_ generateNewType: @escaping (Combiner) -> T) -> Generator<T> {
//        return Generator<T> { size, rng in
//            let combiner = Combiner(size: size, rng: &rng)
//            let newType = generateNewType(combiner)
//            return newType
//        }
//    }
//}
//
//struct Point {
//    var x: Int
//    var y: Int
//}
//
//func testCombine() {
//    let pointGenerator = Generator<Point>.combine { combiner -> Point in
//        let x = combiner.generate(generator: Int.generator)
//        let y = combiner.generate(generator: Int.generator)
//        return Point(x: x, y: y)
//    }
//}
