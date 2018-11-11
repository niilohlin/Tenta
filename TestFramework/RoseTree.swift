//
//  RoseTree.swift
//  TestFramework
//
//  Created by Niil Öhlin on 2018-10-09.
//  Copyright © 2018 Niil Öhlin. All rights reserved.
//

import Foundation

// Non empty, multi way tree
struct RoseTree<Value> {
    let root: () -> Value
    let forest: () -> [RoseTree<Value>]

    init(root: @escaping () -> Value, forest: @escaping () -> [RoseTree<Value>]) {
        self.root = root
        self.forest = forest
    }

    // Maybe name generateFunction
    // `unfold`
    init(seed: Value, _ unfoldFunction: @escaping (Value) -> [Value]) {
        root = { seed }
        forest = {
            RoseTree.generateForest(seed: seed, unfoldFunction)
        }
    }

    // `unfoldForest`
    static func generateForest<T>(seed: T, _ unfoldFunction: @escaping (T) -> [T]) -> [RoseTree<T>] {
        return unfoldFunction(seed).map { RoseTree<T>(seed: $0, unfoldFunction) }
    }

    func expand(_ f: @escaping (Value) -> [Value]) -> RoseTree<Value> {
        let root = self.root()
        let forest = self.forest()
        return RoseTree(root: { root }, forest: { forest.map { $0.expand(f) } + RoseTree<Value>.generateForest(seed: root, f)  })
    }
}

extension RoseTree: Sequence {
    public func makeIterator() -> RoseIterator<Value> {
        return RoseIterator(roseTree: self)
    }
}

struct RoseIterator<Value>: IteratorProtocol {
    var roseTree: RoseTree<Value>
    var queue: [RoseTree<Value>] = []

    init(roseTree: RoseTree<Value>) {
        self.roseTree = roseTree
        queue.append(roseTree)
    }

    public mutating func next() -> RoseTree<Value>? {
        guard let roseTree = queue.popLast() else {
            return nil
        }
        queue = roseTree.forest().reversed() + queue
        return roseTree
    }
}

extension RoseTree {
    func map<T>(_ f: @escaping (Value) -> T) -> RoseTree<T> {
        return RoseTree<T>(root: { f(self.root()) }, forest: { self.forest().map { $0.map(f) } })
    }

    func flatMap<T>(_ createNewTree: @escaping (Value) -> RoseTree<T>) -> RoseTree<T> {
        let rose = createNewTree(root())
        return RoseTree<T>(root: rose.root, forest: { (rose.forest() + self.forest().map { $0.flatMap(createNewTree) } )})
    }

    func printTree(indentation: String = "") {
        print(indentation + "\(root())")
        forest().forEach { tree in
            tree.printTree(indentation: indentation + "  ")
        }
    }


//    static func expandTree(initial: Value, _ f: @escaping (Value) -> [Value]) -> [RoseTree<Value>] {
//        print("initial value: \(initial)")
//        print("values: \(f(initial))")
//        return f(initial).map { val in
//            RoseTree(root: { val }, forest: { expandTree(initial: val, f) })
//        }
//    }
}
