//
//  Icon.swift
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

protocol IconSortable {
  var url: URL { get }
  var type: IconType { get }
  var size: IconSize? { get }

  static func sort<T: IconSortable>(results: [T], preferredSize: IconSize?, preferredType: IconType?) -> [T]
}

extension IconSortable {

  /// Sort the array.
  /// First, split to two array, first array match the icon type -> [matchedType, normalType]
  /// Second, sort arrays by abs between icon size and preferredSize. If preferredSize is nil, sort by icon size.
  /// Third, merge arrays and return.
  static func sort<T: IconSortable>(results: [T], preferredSize: IconSize?, preferredType: IconType?) -> [T] {
    /// split into two array, first array match the  icon type
    let (matchedType, normalType): ([T], [T]) = {
      var matchedType: [T] = []
      var normalType: [T] = []
      for value in results {
        if preferredType == .some(value.type) {
          matchedType.append(value)
        } else {
          normalType.append(value)
        }
      }
      return (matchedType, normalType)
    }()
    /// sort by abs of size.
    let sizeSorter = { (left: IconSortable, right: IconSortable) -> Bool in
      guard let preferredSize = preferredSize else {
        guard let leftSize = left.size else { return false }
        guard let rightSize = right.size else { return true }
        return leftSize > rightSize
      }
      guard let leftSize = left.size else { return false }
      guard let rightSize = right.size else { return true }
      return abs(leftSize.totalValue - preferredSize.totalValue) < abs(rightSize.totalValue - preferredSize.totalValue)
    }
    
    return matchedType.sorted { (left, right) in return sizeSorter(left, right) } +
      normalType.sorted { (left, right) in return sizeSorter(left, right) }
  }
}

/// Store width and height of icon.
public struct IconSize: Comparable {
  /// The width of icon
  public let width: Int
  /// The height of icon
  public let height: Int
  
  /// Return value by width + height
  public var totalValue: Int {
    return width + height
  }

  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }
  
  /// Return true when `lhs.width == rhs.width and lhs.height == rhs.height`
  public static func == (lhs: IconSize, rhs: IconSize) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
  }
  
  /// Return true when `lhs.width + rhs.height < lhs.width == rhs.height`
  public static func < (lhs: IconSize, rhs: IconSize) -> Bool {
    return (lhs.width + lhs.height) < (rhs.width + rhs.height)
  }
}

/// struct to store all values assocaited with responses data of  `Request`' s `responseURLs`
public struct Icon: IconSortable {
  /// The URL sent to server.
  public let url: URL
  /// The type of icon.
  public let type: IconType
  /// The size of icon.
  public let size: IconSize?
  /// The mime type of icon
  public let mimeType: String?
  
  /// Creates a `Icon` instance
  /// - Parameters:
  ///   - url: The URL sent to server.
  ///   - type: The type of icon.
  ///   - size: The size of icon.
  init(url: URL, type: IconType, size: IconSize? = nil, mimeType: String? = nil) {
    self.url = url
    self.type = type
    self.size = size
    self.mimeType = mimeType
  }
}

/// struct to store all values assocaited with responses data of  `Request`' s `responseIconData`
public struct IconData: IconSortable {
  /// The data of icon.
  public let data: Data
  /// The URL sent to server.
  public let url: URL
  /// The type of icon.
  public let type: IconType
  /// The size of icon.
  public let size: IconSize?

  
  /// Creates a `IconData` instance
  /// - Parameters:
  ///   - data: The data of icon.
  ///   - url: The URL sent to server.
  ///   - type: The type of icon.
  ///   - size: The size of icon.
  init(data: Data, url: URL, type: IconType, size: IconSize? = nil) {
    self.data = data
    self.url = url
    self.type = type
    self.size = size
  }

}


