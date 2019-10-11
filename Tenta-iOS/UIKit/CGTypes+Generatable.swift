//
// Created by Niil Öhlin on 2018-12-16.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit

public extension Generator where ValueToTest == CGFloat {
    static var cgFloat: Generator<CGFloat> {
        return Double.generator.map { CGFloat($0) }
    }
}

extension CGFloat: Generatable {
    public static var generator: Generator<CGFloat> {
        return Generator<CGFloat>.cgFloat
    }
}

public extension Generator where ValueToTest == CGPoint {
    static var cgPoint: Generator<CGPoint> {
        return Generator.combine(CGFloat.generator, CGFloat.generator) { x, y in
            CGPoint(x: x, y: y)
        }
    }
}

extension CGPoint: Generatable {
    public static var generator: Generator<CGPoint> {
        return Generator<CGPoint>.cgPoint
    }
}

public extension Generator where ValueToTest == CGSize {
    static var cgSize: Generator<CGSize> {
        return Generator.combine(CGFloat.generator, CGFloat.generator) { width, height in
            CGSize(width: height, height: height)
        }
    }
}

extension CGSize: Generatable {
    public static var generator: Generator<CGSize> {
        return Generator<CGSize>.cgSize
    }
}

public extension Generator where ValueToTest == CGRect {
    static var cgRect: Generator<CGRect> {
        return Generator.combine(CGPoint.generator, CGSize.generator) { origin, size in
            CGRect(origin: origin, size: size)
        }
    }
}

extension CGRect: Generatable {
    public static var generator: Generator<CGRect> {
        return Generator<CGRect>.cgRect
    }
}

#endif
