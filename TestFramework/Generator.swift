//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

protocol Generator {
    associatedtype Value
    func generate<T: RandomNumberGenerator>(size: Double, rng: inout T) -> RoseTree<Value>
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


struct IntGenerator: Generator {
    let span = Span(origin: 0, span: { (-Int($0), Int($0)) })

    func generate<T: RandomNumberGenerator>(size: Double, rng: inout T) -> RoseTree<Int> {
        if size <= 0 {
            return RoseTree(root: { self.span.origin }, forest: { [] })
        }
        let range = span.span(size).0 ... span.span(size).1
        let value = Int.random(in: range, using: &rng)
        return RoseTree(root: { value }, forest: {
            0.shrinkTowards(destination: value)
        })
    }
}

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

func runTest<Gen: Generator, TestValue>(gen: Gen, predicate: @escaping (TestValue) -> Bool) where Gen.Value == TestValue {
    var rng = SeededRandomNumberGenerator(seed: 100)

    for size in 0..<100 {
        let rose = gen.generate(size: Double(size), rng: &rng)
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
