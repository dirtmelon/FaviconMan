//
// ResponseTests.swift
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

class ResponseTests: XCTestCase {
  private let timeout: TimeInterval = 15.0

  func testResponseURL() {
    let responseExpectation = expectation(description: "response url should eventually fail")
    var result: Result<Icon, FMError>!
    FaviconMan.fman.request("https://www.apple.com")?.responseURL(completionHandler: {
      result = $0
      responseExpectation.fulfill()
    })
    wait(for: [responseExpectation], timeout: timeout)
    XCTAssertNotNil(result != nil)
    if case .success(let icon) = result {
      XCTAssertTrue(!icon.url.absoluteString.isEmpty)
    } else {
       XCTFail("can not fetch url of icon")

    }
  }
  
  func testResponseURLs() {
    let responseExpectation = expectation(description: "response url should eventually fail")
    var result: Result<[Icon], FMError>!
    FaviconMan.fman.request("https://www.apple.com", preferredIconType: .classic)?.responseURLs(completionHandler: {
      result = $0
      responseExpectation.fulfill()
    })
    wait(for: [responseExpectation], timeout: timeout)
    XCTAssertNotNil(result)
    if case .success(let icons) = result {
      XCTAssertEqual(2, icons.count)
      XCTAssertEqual(URL(string: "https://www.apple.com/favicon.ico")!, icons[0].url)
    } else {
      XCTFail("can not fetch url of icons")
    }
  }

  func testResponseData() {
    let responseExpectation = expectation(description: "response data should eventually fail")
    var result: Result<IconData, FMError>!
    FaviconMan.fman.request("https://www.apple.com")?.responseIconData(completionHandler: {
      result = $0
      responseExpectation.fulfill()
    })
    wait(for: [responseExpectation], timeout: 30.0)
    XCTAssertNotNil(result)
    if case .success(let iconData) = result {
      XCTAssertNotNil(iconData.data)
      XCTAssertTrue(!iconData.url.absoluteString.isEmpty)
    } else {
      XCTFail("can not fetch data of icon")
    }
  }

  func testResponseDataPreferredIconType() {
    let responseExpectation = expectation(description: "response data should eventually fail")
    var result: Result<IconData, FMError>!
    FaviconMan.fman.request("https://www.apple.com",
                            preferredIconType: .classic)?.responseIconData(completionHandler: {
      result = $0
      responseExpectation.fulfill()
    })
    wait(for: [responseExpectation], timeout: 30.0)
    XCTAssertNotNil(result)
    if case .success(let iconData) = result {
      XCTAssertNotNil(iconData.data)
      XCTAssertTrue(!iconData.url.absoluteString.isEmpty)
      XCTAssertTrue(iconData.type == .classic)
    } else {
      XCTFail("can not fetch data of icon")
    }
  }

  func testResponseDatas() {
    let responseExpectation = expectation(description: "response data should eventually fail")
    var results: [Result<IconData, FMError>]!
    FaviconMan.fman.request("https://www.apple.com")?.responseIconDatas(completionHandler: {
      results = $0
      responseExpectation.fulfill()
    })
    wait(for: [responseExpectation], timeout: 100.0)
    XCTAssertNotNil(results)
    XCTAssertTrue(results.count == 2)
    if case .success(let iconData) = results[0] {
      XCTAssertEqual(URL(string: "https://www.apple.com/favicon.ico")!, iconData.url)
      XCTAssertTrue(iconData.type == .classic)
      XCTAssertNotNil(iconData.data)
    } else {
      XCTFail("can not fetch data of icon")
    }

  }
}
