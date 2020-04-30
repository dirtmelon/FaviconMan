//
//  HTMLDocument.swift
//  FaviconMan
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

import Foundation
import libxml2

class HTMLDocument {
  private var docPtr: htmlDocPtr?

  init?(data: Data) {
    guard data.count > 0 else { return nil }
    // disable error log.
    initGenericErrorDefaultFunc(nil)
    xmlSetStructuredErrorFunc(nil) { (data, error) in }
    xmlKeepBlanksDefault(0)
    
    docPtr = data.withUnsafeBytes{
      return htmlReadMemory($0.bindMemory(to: Int8.self).baseAddress, Int32(data.count), nil, nil, 0)
    }
  }

  func query(for xpath: String) -> [HTMLElement] {
    var results: [HTMLElement] = []
    guard let docPtr = docPtr,
      let context = xmlXPathNewContext(docPtr) else {
        return results
    }
    var xPathObjectPtr: xmlXPathObjectPtr!

    defer {
      xmlXPathFreeContext(context)
      xmlXPathFreeObject(xPathObjectPtr)
    }

    xpath.withCString { stringPointer in
      stringPointer.withMemoryRebound(to: UInt8.self, capacity: 1) { pointer in
        xPathObjectPtr = xmlXPathEvalExpression(pointer, context)
      }
    }

    for index in 0..<xPathObjectPtr.pointee.nodesetval.pointee.nodeNr {
      guard let node = xPathObjectPtr.pointee.nodesetval.pointee.nodeTab.advanced(by: Int(index)).pointee else {
        continue
      }
      results.append(HTMLElement(document: self, nodePtr: node))
    }
    return results
  }
}
