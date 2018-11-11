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
    }
}

extension Array {
    func splitAt(position: Int) -> ([Element], [Element]) {
        let firstHalf = self.dropLast(position)
        let secondHalf = self.dropFirst(position)
        return (Array(firstHalf), Array(secondHalf))
    }

    func removing(numberOfElements: Int) -> [[Element]] {
        return removing(numberOfElements: numberOfElements, self.count)
    }

    private func removing(numberOfElements: Int, _ count: Int) -> [[Element]] {
        let (firstHalf, secondHalf) = self.splitAt(position: numberOfElements)
        if numberOfElements > count {
            return []
        } else if secondHalf.isEmpty {
            return [[]]
        } else {
            return [secondHalf] + secondHalf.removing(numberOfElements: numberOfElements, count - numberOfElements).map { firstHalf + $0 }
        }



    }
}
