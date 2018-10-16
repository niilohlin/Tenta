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

    public mutating func next() -> Value? {
        guard let roseTree = queue.popLast() else {
            return nil
        }
        let value = roseTree.root()
        queue = roseTree.forest().reversed() + queue
        return value
    }
}

extension RoseTree {
    func printTree(indentation: String = "") {
        print(indentation + "\(root())")
        forest().forEach { tree in
            tree.printTree(indentation: indentation + "  ")
        }
    }
}
