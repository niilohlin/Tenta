//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension AnyGenerator where ValueToTest == Data {
    static var data: AnyGenerator<Data> {
        [UInt8].generator.map { Data($0) }
    }
}

extension Data: Generatable {
    public static var generator: AnyGenerator<Data> {
        Tenta.AnyGenerator<Data>.data
    }
}

public extension AnyGenerator where ValueToTest == URLQueryItem {
    static var urlQueryItem: AnyGenerator<URLQueryItem> {
        String.generator.combine(with: (String?).generator).map {
            URLQueryItem(name: $0, value: $1)
        }
    }
}

extension URLQueryItem: Generatable {
    public static var generator: AnyGenerator<URLQueryItem> {
        Tenta.AnyGenerator<URLQueryItem>.urlQueryItem
    }
}

//public extension AnyGenerator where ValueToTest == URLComponents {
//    static var urlComponents: AnyGenerator<URLComponents> {
//        return AnyGenerator.simple { (constructor: inout Constructor) -> URLComponents in
//            var components = URLComponents()
//            components.fragment = AnyGenerator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.host = AnyGenerator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.password = AnyGenerator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.path = AnyGenerator<String>.alphaNumeric.generateUsing(&constructor)
//            components.port = Int.generator.map(abs).generateUsing(&constructor)
//            components.queryItems = [URLQueryItem].generator.optional().generateUsing(&constructor)
//            components.scheme = AnyGenerator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.user = AnyGenerator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            return components
//        }
//    }
//}
//
//extension URLComponents: Generatable {
//    public static var generator: AnyGenerator<URLComponents> {
//        return Tenta.Generator<URLComponents>.urlComponents
//    }
//}
