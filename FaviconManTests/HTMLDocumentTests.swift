//
// HTMLDocumentTests.swift
// FaviconManTests
//
//  Copyright (c) 2020-2020 FavcionMan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
import Foundation
@testable import FaviconMan

class HTMLDocumentTests: XCTestCase {
  func testHTML() {
    let document = HTMLDocument(data: "<html></html>".data(using: .utf8)!)
    let elements = document!.query(for: "/html")
    XCTAssertEqual(1, elements.count)
  }

  func testAttributes() {
    let string = "<html><head><link rel=\"shortcut icon\" href=\"shortcut.ico\"></head></html>"
    let document = HTMLDocument(data: string.data(using: .utf8)!)
    let elements = document!.query(for: "/html/head/link")
    XCTAssertEqual(1, elements.count)
    XCTAssertEqual("shortcut icon", elements[0].attributes["rel"])
    XCTAssertEqual("shortcut.ico", elements[0].attributes["href"])
  }
}
