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

    /// Shrink towards `self` from `from`
    func towards(from: Int) -> [Int] {
        if self == from {
            return []
        }
        let difference = from / 2 - self / 2
        let result = difference.halves().map { from - $0 }
        return result.contains(self) ? result : [self] + result
    }

    func shrinkFrom(source: Int) -> [RoseTree<Int>] {
        RoseTree<Int>.generateForest(seed: source) { smaller in
            self.towards(from: smaller)
        }
    }
}

extension UInt {
    func halves() -> [UInt] {
        var result: [UInt] = []
        var half = self
        while true {
            if half == 0 {
                return result
            }
            result.append(half)
            half /= 2
        }
    }

    /// Shrink towards `self` from `from`
    func towards(from: UInt) -> [UInt] {
        if self == from {
            return []
        }
        let difference = from / 2 - self / 2
        let result = difference.halves().map { from - $0 }
        return result.contains(self) ? result : [self] + result
    }

    func shrinkFrom(source: UInt) -> [RoseTree<UInt>] {
        RoseTree<UInt>.generateForest(seed: source) { smaller in
            self.towards(from: smaller)
        }
    }
}

extension UInt8 {
    func halves() -> [UInt8] {
        var result: [UInt8] = []
        var half = self
        while true {
            if half == 0 {
                return result
            }
            result.append(half)
            half /= 2
        }
    }

    /// Shrink towards `self` from `from`
    func towards(from: UInt8) -> [UInt8] {
        if self == from {
            return []
        }
        let difference = from / 2 - self / 2
        let result = difference.halves().map { from - $0 }
        return result.contains(self) ? result : [self] + result
    }

    func shrinkFrom(source: UInt8) -> [RoseTree<UInt8>] {
        RoseTree<UInt8>.generateForest(seed: source) { smaller in
            self.towards(from: smaller)
        }
    }
}

extension Array {
    func shrink() -> [[Element]] {
        self.count.halves().flatMap { halve in
            self.removing(numberOfElements: halve)
        }
    }

    func splitAt(position: Int) -> ([Element], [Element]) {
        if position <= 0 {
            return ([], self)
        }
        if position >= count {
            return (self, [])
        }
        let firstHalf = self.prefix(position)
        let secondHalf = self.dropFirst(position)
        return (Array(firstHalf), Array(secondHalf))
    }

    func removing(numberOfElements: Int) -> [[Element]] {
        removing(numberOfElements: numberOfElements, self.count)
    }

    private func removing(numberOfElements: Int, _ count: Int) -> [[Element]] {
        let (firstHalf, secondHalf) = self.splitAt(position: numberOfElements)
        if numberOfElements > count {
            return []
        } else if secondHalf.isEmpty {
            return [[]]
        } else {
            return [secondHalf] + secondHalf
                    .removing(numberOfElements: numberOfElements, count - numberOfElements)
                    .map { firstHalf + $0 }
        }
    }
}

extension RoseTree {
    func shrink(maxShrinks: Int = .max, predicate: @escaping (Value) -> Bool) -> Value {
        var currentForest = forest()
        var cont = true
        var failedValue = root()
        var maxShrinks = maxShrinks
        while cont && maxShrinks >= 0 {
            if currentForest.isEmpty {
                break
            }
            cont = false

            for subRose in currentForest {
                if !predicate(subRose.root()) {
                    cont = true
                    currentForest = subRose.forest()
                    failedValue = subRose.root()
                    break
                }
            }
            maxShrinks -= 1
        }
        return failedValue
    }

    func shrink(rng: inout SeededRandomNumberGenerator, predicate: @escaping (Value) -> Bool) -> Value {
        var currentForest = forest()
        var cont = true
        var failedValue = root()
        while cont {
            if currentForest.isEmpty {
                break
            }
            cont = false

            let shuffledForest = currentForest.shuffled(using: &rng)
            for subRose in shuffledForest {
                if !predicate(subRose.root()) {
                    cont = true
                    currentForest = subRose.forest()
                    failedValue = subRose.root()
                    break
                }

            }
        }
        return failedValue

    }
}
