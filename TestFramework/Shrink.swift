//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

extension Int {
    func halves() -> [Int] {
        var result: [Int] = []
        var half = self
        while true {
            if half == 0 {
                return result
            }
            if half == -1 {
                return result + [-1]
            }
            result.append(half)
            half /= 2
        }
    }

    func towards(destination: Int) -> [Int] {
        if self == destination {
            return []
        }
        let difference = destination / 2 - self / 2
        let result = difference.halves().map { destination - $0 }
        return result.contains(self) ? result : [self] + result
    }

    func shrinkTowards(destination: Int) -> [RoseTree<Int>] {
        return RoseTree<Int>.generateForest(seed: destination) { smaller in
            0.towards(destination: self)
        }
//        return towards(destination: destination).filter { $0 != self }.map { smaller in
//            RoseTree(root: { smaller }, forest: { smaller.shrinkTowards(destination: destination) })
//        }
    }
}
