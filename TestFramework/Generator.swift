//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

//protocol Generator {
//    associatedtype Value
//    func generate<T: RandomNumberGenerator>(size: Double, rng: inout T) -> RoseTree<Value>
//}

struct Generator<T, RNG: RandomNumberGenerator> {
    let generate: (Double, inout RNG) -> RoseTree<T>
}

//struct Gen<Value>: Generator {
//    let span: Span<Value>
//    func generate<T: RandomNumberGenerator>(size: Double, rng: inout T) -> RoseTree<Value> {
//        if size <= 0 {
//            return RoseTree(root: { self.span.origin }, forest: { [] })
//        }
//        let range = span.span(size).0 ... span.span(size).1
//        let value = Int.random(in: range, using: &rng)
//        return RoseTree(root: { value }, forest: { [] })
//    }
//}

extension Generator {
    static func int<RNG: RandomNumberGenerator>() -> Generator<Int, RNG> {
        let span = Span(origin: 0, span: { (-Int($0), Int($0)) })
        return Generator<Int, RNG> { size, rng in
            if size <= 0 {
                return RoseTree(root: { span.origin }, forest: { [] })
            }
            let range = span.span(size).0 ... span.span(size).1
            let value = Int.random(in: range, using: &rng)
            return RoseTree(root: { value }, forest: {
                0.shrinkTowards(destination: value)
            })

        }
    }

    static func array<TestValue, RNG: RandomNumberGenerator>(elementGenerator: Generator<TestValue, RNG>) -> Generator<[TestValue], RNG> {
        let span = Span(origin: 0, span: { (0, Int($0)) })
        return Generator<[TestValue], RNG> { size, rng in
            if size <= 0 {
                return RoseTree(root: { [] }, forest: { [] })
            }
            let range = span.span(size).0 ... span.span(size).1
            var value = [RoseTree<TestValue>]()
            for _ in range {
                value.append(elementGenerator.generate(size, &rng))
            }
            return RoseTree<[Int]>.sequence(forest: value).flatMap { array in
                RoseTree(seed: array, { $0.shrink() })
            }
//            let finalArrayWithValues = value.map { $0.root() }
//
//            return RoseTree<[TestValue]>(seed: finalArrayWithValues) { (parent: [TestValue]) -> [[TestValue]] in
//                parent.shrink()
//            }
        }
    }
}

//struct ArrayGenerator<Element>: Generator {
//    let elementGenerator: Generator
//    let span = Span(origin: 0, span: { (-Int($0), Int($0)) })
//
//    func generate<T: RandomNumberGenerator>(size: Double, rng: inout T) -> RoseTree<[Element]> {
//        if size <= 0 {
//            return RoseTree(root: { self.span.origin }, forest: { [] })
//        }
//        let range = span.span(size).0 ... span.span(size).1
//        let value = Int.random(in: range, using: &rng)
//        return RoseTree(root: { value }, forest: {
//            0.shrinkTowards(destination: value)
//        })
//    }
//
//}

func shrink<TestValue>(_ rose: RoseTree<TestValue>, predicate: @escaping (TestValue) -> Bool) -> TestValue{
//    rose.printTree()
    var forest = rose.forest()
    var cont = true
    var failedValue = rose.root()
    while cont {
        if forest.isEmpty {
            break
        }
        cont = false

        for subRose in forest {
            if !predicate(subRose.root()) {
                cont = true
                forest = subRose.forest()
                failedValue = subRose.root()
                break
            }

        }
    }
    return failedValue
}

func runTest<TestValue>(gen: Generator<TestValue, SeededRandomNumberGenerator>, predicate: @escaping (TestValue) -> Bool) {
    var rng = SeededRandomNumberGenerator(seed: 100)

    for size in 0..<100 {
        let rose = gen.generate(Double(size), &rng)
        if !predicate(rose.root()) {
            let failedValue = shrink(rose, predicate: predicate)
            print("failed with value: \(failedValue)")
            break
        }
    }
}


//func usage() {
//    runTest(Gen<Int>.linear) { int in
//        return int > 0
//    }
//}
