//
// Created by Niil Öhlin on 2018-10-09.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

protocol Generator {
    associatedtype Value
    func generate(size: Int, seed: Int) -> RoseTree<Value>
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



//func usage() {
//    test(Int.linear) { int in
//        return int > 0
//    }
//}
