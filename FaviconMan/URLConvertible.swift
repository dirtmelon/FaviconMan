//
//  URLConvertible.swift
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

public protocol URLConvertible {
  func asURL() -> URL?
}

extension String: URLConvertible {
  /// - Returns: The `URL` initialized from `self`.
  public func asURL() -> URL? {
    guard let url = URL(string: self) else {
      return nil
    }
    return url
  }

}

extension URL: URLConvertible {
  /// Returns `self`.
  public func asURL() -> URL? {
    return self
  }
}

extension URLComponents: URLConvertible {
  /// - Returns: The `URL` from the `url` property.
  public func asURL() -> URL? {
    guard let url = url else {
      return nil
    }
    return url
  }
}
