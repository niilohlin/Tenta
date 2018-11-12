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

    init(root: @escaping () -> Value, forest: @escaping () -> [RoseTree<Value>] = { [] }) {
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

    func expand(_ expandFunction: @escaping (Value) -> [Value]) -> RoseTree<Value> {
        let root = self.root()
        let forest = self.forest()
        return RoseTree(root: { root }, forest: {
            forest.map { $0.expand(expandFunction) } + RoseTree<Value>.generateForest(seed: root, expandFunction)
        })
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
    func map<T>(_ transform: @escaping (Value) -> T) -> RoseTree<T> {
        return RoseTree<T>(root: { transform(self.root()) }, forest: { self.forest().map { $0.map(transform) } })
    }

    func flatMap<T>(_ createNewTree: @escaping (Value) -> RoseTree<T>) -> RoseTree<T> {
        let rose = createNewTree(root())
        return RoseTree<T>(root: rose.root) {
            (rose.forest() + self.forest().map { $0.flatMap(createNewTree) })
        }
    }

    func printTree(indentation: String = "") {
        print(indentation + "\(root())")
        forest().forEach { tree in
            tree.printTree(indentation: indentation + "  ")
        }
    }

    static func sequence<TestValue>(forest: [RoseTree<TestValue>]) -> RoseTree<[TestValue]> {
        guard let first = forest.first else {
            return RoseTree<[TestValue]>(root: { [] })
        }
        let rest = Array(forest.dropFirst())
        return first.flatMap { (value: TestValue) in
            sequence(forest: rest).flatMap { (other: [TestValue]) in
                RoseTree<[TestValue]>(root: { [value] + other })
            }
        }
    }
}
