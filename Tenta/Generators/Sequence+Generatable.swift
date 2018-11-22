//
// Created by Niil Öhlin on 2018-11-22.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator {
    /**
     Generates arrays of type `TestValue` and shrinks towards `[]`.

     - Usage:
     ```
     let intGenerator: Generator<Int> = Generator<Int>.int
     runTest(gen: Generator<Int>.array(elementGenerator: intGenerator)) { array in
         array.count >= 0
     }
     ```
     - Parameter elementGenerator: Generator used when generating the values of the array.
     - Returns: A generator that generates arrays.
     */
    static func array<TestValue>(
            elementGenerator: Generator<TestValue>) -> Generator<[TestValue]> {
        return Generator<[TestValue]> { size, rng in
            if size <= 0 {
                return RoseTree(root: { [] }, forest: { [] })
            }
            var value = [RoseTree<TestValue>]()
            for _ in 0 ... Int(size) {
                value.append(elementGenerator.generate(size, &rng))
            }
            let resultingArray = value.map { $0.root() }
            return RoseTree<[TestValue]>(seed: resultingArray) { (parentArray: [TestValue]) in
                parentArray.shrink()
            }
//            return RoseTree<[Int]>.combine(forest: value).flatMap { array in
//                RoseTree(seed: array) { (parentArray: [TestValue]) in
//                    parentArray.shrink()
//                }
//            }
        }
    }

    func generateMany() -> Generator<[ValueToTest]> {
        return Generator<[ValueToTest]>.array(elementGenerator: self)
    }
}

extension Array: Generatable where Array.Element: Generatable {
    /// The default int generator. Generates `Arrays`s according to the `size` parameter.
    public static var generator: Generator<[Array.Element]> {
        let generator: Generator<Element> = Element.generator
        return Tenta.Generator<Any>.array(elementGenerator: generator)
    }
}
