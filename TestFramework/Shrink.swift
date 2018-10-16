//
// Created by Niil Öhlin on 2018-10-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

extension Int {
    func halves() -> [Int] {
        if self == 0 {
            return []
        }
        if self == -1 {
            return []
        }
        return [self] + (self / 2).halves()
    }

    func towards(destination: Int) -> [Int] {
        if self == destination {
            return []
        }
        if self > destination {
            return destination.towards(destination: self)
        }
        let difference = destination / 2 - self / 2
        return [self] + difference.halves().map { destination - $0 }
    }

    func shrinkTowards(destination: Int) -> [RoseTree<Int>] {
        return self.towards(destination: destination).map { smaller in
            RoseTree(root: { smaller }, forest: { smaller.shrinkTowards(destination: destination) })
        }
    }
}
