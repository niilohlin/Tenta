//
//  RoseTree.swift
//  Tenta
//
//  Created by Niil Öhlin on 2018-10-09.
//  Copyright © 2018 Niil Öhlin. All rights reserved.
//

import Foundation

/// Non empty, multi way lazy tree. Used to hold the generated value in the `root` and the shrink values in the `forest`
public struct RoseTree<Value> {
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

public struct RoseIterator<Value>: IteratorProtocol {
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

public extension RoseTree {
    func map<T>(_ transform: @escaping (Value) -> T) -> RoseTree<T> {
        return RoseTree<T>(root: { transform(self.root()) }, forest: { self.forest().map { $0.map(transform) } })
    }

    func flatMap<T>(_ createNewTree: @escaping (Value) -> RoseTree<T>) -> RoseTree<T> {
        let rose = createNewTree(root())
        return RoseTree<T>(root: rose.root) {
            (rose.forest() + self.forest().map { $0.flatMap(createNewTree) })
        }
    }

    func filter(_ predicate: @escaping (Value) -> Bool) -> RoseTree<Value>? {
        let rootValue = root()
        guard predicate(rootValue) else {
            return nil
        }
        return RoseTree(root: { rootValue }, forest: {
            self.forest().compactMap { $0.filter(predicate) }
        })
    }

    static func combine<TestValue>(forest: [RoseTree<TestValue>]) -> RoseTree<[TestValue]> {
        guard let first = forest.first else {
            return RoseTree<[TestValue]>(root: { [] })
        }
        let rest = Array(forest.dropFirst())
        return first.flatMap { (value: TestValue) in
            combine(forest: rest).flatMap { (other: [TestValue]) in
                RoseTree<[TestValue]>(root: { [value] + other })
            }
        }
    }

    func combine<OtherValue, Transformed>(
            with other: RoseTree<OtherValue>,
            transform: @escaping (Value, OtherValue) -> Transformed) -> RoseTree<Transformed> {
        let firstRoot = root()
        let secondRoot = other.root()
        return RoseTree<Transformed>(root: { transform(firstRoot, secondRoot) }, forest: {
            let firstForest = self.forest()
            let secondForest = other.forest()
            let mapTransformWithFirstRoot = { (rose: RoseTree<OtherValue>) -> RoseTree<Transformed> in
                rose.map { transform(firstRoot, $0) }
            }
            return secondForest.map(mapTransformWithFirstRoot) + firstForest.map { firstSubForest in
                firstSubForest.combine(with: other, transform: transform)
            }
        })
    }
}

extension RoseTree: CustomStringConvertible {
    public var description: String {
        return getDescription(depth: 0)
    }

    private func getDescription(depth: Int) -> String {
        let indentation = String(repeating: "  ", count: depth)
        guard depth < 10 else {
            return indentation + "...\n"
        }
        return indentation + String(describing: root()) +
                "\n" +
                forest().map { $0.getDescription(depth: depth + 1) }.joined()
    }
}
