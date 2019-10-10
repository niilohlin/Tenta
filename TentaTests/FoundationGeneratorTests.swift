//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import Tenta
import XCTest

class FoundationGeneratorTests: XCTestCase {
    func testURLQueryItems() {
        testPropertyWithXCTest { (urlQueryItem: URLQueryItem) in
            XCTAssertEqual(urlQueryItem, urlQueryItem)
        }
    }

    func testData() {
        testPropertyWithXCTest { (data: Data) in
            XCTAssertEqual(data, data)
        }
    }
}
