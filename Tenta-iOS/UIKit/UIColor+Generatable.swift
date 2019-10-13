//
//  UIColor+Generatable.swift
//  Tenta-iOS
//
//  Created by Niil Öhlin on 2019-01-02.
//  Copyright © 2019 Niil Öhlin. All rights reserved.
//

import Foundation
import UIKit

public extension Generator where ValueToTest == UIColor {
    static var color: Generator<UIColor> {
        return Generator.combine([Generator<UInt8>](repeating: UInt8.generator, count: 4)) { array in
            UIColor(
                    red: CGFloat(array[0]) / CGFloat(UInt8.max),
                    green: CGFloat(array[1]) / CGFloat(UInt8.max),
                    blue: CGFloat(array[2]) / CGFloat(UInt8.max),
                    alpha: CGFloat(array[3]) / CGFloat(UInt8.max)
            )
        }
    }

}

// cannot conform due to swifts type system.
//extension UIColor: Generatable {
//    public static var generator: Generator<UIColor> {
//        return Generator<UIColor>.color
//    }
//}
