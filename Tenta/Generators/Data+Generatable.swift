//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation

public extension Generator where ValueToTest == Data {
    static var data: Generator<Data> {
        [UInt8].generator.map { Data($0) }
    }
}

extension Data: Generatable {
    public static var generator: Generator<Data> {
        Tenta.Generator<Data>.data
    }
}

public extension Generator where ValueToTest == URLQueryItem {
    static var urlQueryItem: Generator<URLQueryItem> {
        String.generator.combine(with: (String?).generator).map {
            URLQueryItem(name: $0, value: $1)
        }
    }
}

extension URLQueryItem: Generatable {
    public static var generator: Generator<URLQueryItem> {
        Tenta.Generator<URLQueryItem>.urlQueryItem
    }
}

//public extension Generator where ValueToTest == URLComponents {
//    static var urlComponents: Generator<URLComponents> {
//        return Generator.simple { (constructor: inout Constructor) -> URLComponents in
//            var components = URLComponents()
//            components.fragment = Generator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.host = Generator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.password = Generator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.path = Generator<String>.alphaNumeric.generateUsing(&constructor)
//            components.port = Int.generator.map(abs).generateUsing(&constructor)
//            components.queryItems = [URLQueryItem].generator.optional().generateUsing(&constructor)
//            components.scheme = Generator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            components.user = Generator<String>.alphaNumeric.optional().generateUsing(&constructor)
//            return components
//        }
//    }
//}
//
//extension URLComponents: Generatable {
//    public static var generator: Generator<URLComponents> {
//        return Tenta.Generator<URLComponents>.urlComponents
//    }
//}
