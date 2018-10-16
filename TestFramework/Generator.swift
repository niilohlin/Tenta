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

func generateIntegers(range: Range<Int>) -> RoseTree<Int> {
    let value = Int.random(in: range)
    let lowerRange = Range(uncheckedBounds: (lower: range.lowerBound - 1, upper: range.upperBound))
    let upperRange = Range(uncheckedBounds: (lower: range.lowerBound, upper: range.upperBound + 1))
    return RoseTree(root: { value }, forest: { [generateIntegers(range: lowerRange), generateIntegers(range: upperRange)] })
}

func generateArrayOfIntegers(range: Range<Int>) -> RoseTree<[Int]> {
    fatalError()
}

func runTest<Gen: Generator, TestValue>(gen: Gen, predicate: @escaping (TestValue) -> Bool) where Gen.Value == TestValue {
    print("starting test")
    var rng = SeededRandomNumberGenerator(seed: 100)
    for size in 0..<100 {
        let rose = gen.generate(size: Double(size), rng: &rng)
        if !predicate(rose.root()) {
            print("test failed with \(rose.root())")
            break
        }
    }
}


//func usage() {
//    runTest(Gen<Int>.linear) { int in
//        return int > 0
//    }
//}
