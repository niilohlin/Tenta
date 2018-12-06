//
// Created by Niil Öhlin on 2018-12-06.
// Copyright (c) 2018 Niil Öhlin. All rights reserved.
//

import Foundation
import Tenta
import XCTest

class FoundationGeneratorTests: XCTestCase {
    func testURLQueryItems() {
        runWithXCTest { (urlQueryItem: URLQueryItem) in
            XCTAssertEqual(urlQueryItem, urlQueryItem)
        }
    }

    func testData() {
        runWithXCTest { (data: Data) in
            XCTAssertEqual(data, data)
        }
    }
}
