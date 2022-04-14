//
// Created by Niil Öhlin on 2018-12-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension AnyGenerator where ValueToTest == CGFloat {
    static var cgFloat: AnyGenerator<CGFloat> {
        return Double.generator.map { CGFloat($0) }
    }
}

extension CGFloat: Generatable {
    public static var generator: AnyGenerator<CGFloat> {
        return AnyGenerator<CGFloat>.cgFloat
    }
}

public extension AnyGenerator where ValueToTest == CGPoint {
    static var cgPoint: AnyGenerator<CGPoint> {
        return AnyGenerator.combine(CGFloat.generator, CGFloat.generator) { x, y in
            CGPoint(x: x, y: y)
        }
    }
}

extension CGPoint: Generatable {
    public static var generator: AnyGenerator<CGPoint> {
        return AnyGenerator<CGPoint>.cgPoint
    }
}

public extension AnyGenerator where ValueToTest == CGSize {
    static var cgSize: AnyGenerator<CGSize> {
        return AnyGenerator.combine(CGFloat.generator, CGFloat.generator) { width, height in
            CGSize(width: height, height: height)
        }
    }
}

extension CGSize: Generatable {
    public static var generator: AnyGenerator<CGSize> {
        return AnyGenerator<CGSize>.cgSize
    }
}

public extension AnyGenerator where ValueToTest == CGRect {
    static var cgRect: AnyGenerator<CGRect> {
        return AnyGenerator.combine(CGPoint.generator, CGSize.generator) { origin, size in
            CGRect(origin: origin, size: size)
        }
    }
}

extension CGRect: Generatable {
    public static var generator: AnyGenerator<CGRect> {
        return AnyGenerator<CGRect>.cgRect
    }
}

#endif
