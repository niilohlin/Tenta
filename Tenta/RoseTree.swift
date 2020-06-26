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

    init(root: @autoclosure @escaping () -> Value, forest: @autoclosure @escaping () -> [RoseTree<Value>] = []) {
        self.root = root
        self.forest = forest
    }

    // Maybe name generateFunction
    // `unfold`
    init(seed: @autoclosure @escaping () -> Value, _ unfoldFunction: @escaping (Value) -> [Value]) {
        root = seed
        forest = {
            RoseTree.generateForest(seed: seed(), unfoldFunction)
        }
    }

    // `unfoldForest`
    static func generateForest<T>(
            seed: @autoclosure @escaping () -> T,
            _ unfoldFunction: @escaping (T) -> [T]
    ) -> [RoseTree<T>] {
        unfoldFunction(seed()).map { RoseTree<T>(seed: $0, unfoldFunction) }
    }

    func expand(_ expandFunction: @escaping (Value) -> [Value]) -> RoseTree<Value> {
        let root = self.root()
        let forest = self.forest()
        return RoseTree(
                root: root,
                forest: forest.map { $0.expand(expandFunction) } +
                            RoseTree<Value>.generateForest(seed: root, expandFunction)
        )
    }
}

extension RoseTree: Sequence {
    public func makeIterator() -> RoseIterator<Value> {
        RoseIterator(roseTree: self)
    }
}

public struct RoseIterator<Value>: IteratorProtocol {
    var queue = [RoseTree<Value>]()

    init(roseTree: RoseTree<Value>) {
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
        RoseTree<T>(root: transform(self.root()), forest: self.forest().map { $0.map(transform) })
    }

    func flatMap<T>(_ createNewTree: @escaping (Value) -> RoseTree<T>) -> RoseTree<T> {
        let rose = createNewTree(root())
        return RoseTree<T>(
                root: rose.root(),
                forest: rose.forest() + self.forest().map { $0.flatMap(createNewTree) }
        )
    }

    func filter(_ predicate: @escaping (Value) -> Bool) -> RoseTree<Value>? {
        let rootValue = root()
        guard predicate(rootValue) else {
            return nil
        }
        return RoseTree(
            root: rootValue,
            forest: self.forest().compactMap { $0.filter(predicate) }
        )
    }

    func compactMap<ElementOfResult>(_ transform: @escaping (Value) -> ElementOfResult?) -> RoseTree<ElementOfResult>? {
        guard let rootValue = transform(root()) else {
            return nil
        }
        return RoseTree<ElementOfResult>(root: rootValue, forest: self.forest().compactMap { subtree in
            subtree.compactMap(transform)
        })
    }

    static func combine<TestValue>(forest: [RoseTree<TestValue>]) -> RoseTree<[TestValue]> {
        guard let first = forest.first else {
            return RoseTree<[TestValue]>(root: [])
        }
        let rest = Array(forest.dropFirst())
        return first.flatMap { (value: TestValue) in
            combine(forest: rest).flatMap { (other: [TestValue]) in
                RoseTree<[TestValue]>(root: [value] + other)
            }
        }
    }

    func combine<OtherValue, Transformed>(
            with other: RoseTree<OtherValue>,
            recurse: Bool = true,
            transform: @escaping (Value, OtherValue) -> Transformed) -> RoseTree<Transformed> {

        self.flatMap { value in
            other.map { transform(value, $0) }
        }
    }

    func appendTree(toBottom other: RoseTree<Value>) -> RoseTree<Value> {
        if self.forest().isEmpty {
            return RoseTree(root: self.root(), forest: [other])
        }
        return RoseTree(root: self.root(), forest: self.forest().map { $0.appendTree(toBottom: other) })
    }
}

extension RoseTree: CustomStringConvertible {
    public var description: String {
        getDescription(depth: 0)
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

extension RoseTree {

    public var dotGraph: String {
        func recursiveDotGraph(subTree: RoseTree<Value>) -> String {
            subTree
                    .forest()
                    .reduce("") { acc, next in
                        acc + "\(subTree.root()) -> \(next.root());\n"
                    } + subTree.forest().map(recursiveDotGraph(subTree:)).joined()
        }

        return """
               digraph BST {
               node [fontname=\"Arial\"];
               \(recursiveDotGraph(subTree: self))
               }

               """
    }
}

extension RoseTree: Equatable where Value: Equatable {
    public static func == (lhs: RoseTree<Value>, rhs: RoseTree<Value>) -> Bool {
        guard lhs.root() == rhs.root() else {
            return false
        }
        return lhs.forest() == rhs.forest()
    }
}

extension RoseTree: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(root())
        for subTree in forest() {
            hasher.combine(subTree)
        }
    }
}
