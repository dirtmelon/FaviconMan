//
// ParserTests.swift
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
@testable import FaviconMan

class ParserTests: XCTestCase {

  func testHTMLHeadLinkIcons() {
    let parser = Parser(data: htmlData(), baseURL: URL(string: "https://www.html.com")!)
    let icons = parser.parseHTMLHeadLinkIcons()
    XCTAssertEqual(19, icons.count)


    XCTAssertEqual("https://www.html.com/shortcut.ico", icons[0].url.absoluteString)
    XCTAssertEqual(IconType.shortcut, icons[0].type)

    XCTAssertEqual("https://www.html.com/favicon.ico", icons[1].url.absoluteString)
    XCTAssertEqual(IconSize(width: 96, height: 96), icons[1].size!)
    XCTAssertEqual(IconType.normal, icons[1].type)
    XCTAssertEqual("image/png", icons[1].mimeType!)

    XCTAssertEqual("https://www.html.com/apple-touch-icon-57x57.png", icons[5].url.absoluteString)
    XCTAssertEqual(IconSize(width: 57, height: 57), icons[5].size!)
    XCTAssertEqual(IconType.appleTouch, icons[5].type)
  }

  func testHTMLHeadMetaIcons() {
    let parser = Parser(data: htmlData(), baseURL: URL(string: "https://www.html.com")!)
    let icons = parser.parseHTMLHeadMetaIcons()

    XCTAssertEqual(6, icons.count)

    XCTAssertEqual("https://www.html.com/mstile-144x144.png", icons[0].url.absoluteString)
    XCTAssertEqual(IconSize(width: 144, height: 144), icons[0].size!)
    XCTAssertEqual(IconType.msapplicationTileImage, icons[0].type)

    XCTAssertEqual(IconSize(width: 70, height: 70), icons[1].size!)
    XCTAssertEqual(IconType.msapplicationSquare70x70logo, icons[1].type)
    XCTAssertEqual(IconType.msapplicationSquare150x150logo, icons[2].type)
    XCTAssertEqual(IconType.msapplicationWide310x150logo, icons[3].type)
    XCTAssertEqual(IconType.msapplicationSquare310x310logo, icons[4].type)
    XCTAssertEqual(IconType.openGraphImage, icons[5].type)
  }

  private func htmlData() -> Data {
    let bundle = Bundle(for: ParserTests.self)
    return FileManager.default.contents(atPath: bundle.path(forResource: "Html", ofType: ".html")!)!
  }
}
