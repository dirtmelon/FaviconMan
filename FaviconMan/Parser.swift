//
//  Parser.swift
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

/// Parse icons for html data and url.
class Parser {

  private let document: HTMLDocument?
  private let baseURL: URL

  init(data: Data, baseURL: URL) {
    self.baseURL = baseURL
    self.document = HTMLDocument(data: data)
  }
  
  /// Parse icons in `/html/head/link`
  /// support types: shortcut icon, icon, apple-touch-icon, apple-touch-icon-precomposed
  /// - Returns: return icons
  func parseHTMLHeadLinkIcons() -> [Icon] {
    guard let document = document else {
      return []
    }
    var icons: [Icon] = []
    for element in document.query(for: "/html/head/link") {
      guard let linkElement = LinkElement(htmlElement: element),
        let url = URL(string: linkElement.href, relativeTo: baseURL),
        let iconType = IconType(rawValue: linkElement.rel) else { continue }
      
      let iconSize: IconSize? = {
        guard let sizeAttributedString = linkElement.sizes,
          sizeAttributedString != "any",
          let sizeString = sizeAttributedString.components(separatedBy: .whitespaces).last else {
            return nil
        }
        return self.iconSize(from: sizeString)
      }()
      icons.append(Icon(url: url,
                        type: iconType,
                        size: iconSize,
                        mimeType: linkElement.mimeType))
    }
    return icons
  }
  
  func parseHTMLHeadMetaIcons() -> [Icon] {
    guard let document = document else {
      return []
    }
    var icons: [Icon] = []
    for element in document.query(for: "/html/head/meta") {
      guard let metaElement = MetaElement(htmlElement: element),
        let url = URL(string: metaElement.content, relativeTo: baseURL) else { continue }
      if let name = metaElement.name?.lowercased(),
        let iconType = IconType(rawValue: name) {
        let iconSize: IconSize? = {
          switch iconType {
          case .msapplicationTileImage:
            return IconSize(width: 144, height: 144)
          case .msapplicationSquare70x70logo:
            return IconSize(width: 70, height: 70)
          case .msapplicationSquare150x150logo:
            return IconSize(width: 150, height: 150)
          case .msapplicationWide310x150logo:
            return IconSize(width: 310, height: 150)
          case .msapplicationSquare310x310logo:
            return IconSize(width: 310, height: 310)
          default:
            return nil
          }
        }()
        icons.append(Icon(url: url, type: iconType, size: iconSize))
        continue
      }
      if let property = metaElement.property?.lowercased(),
        property == "og:image" {
        icons.append(Icon(url: url,
                          type: .openGraphImage))
      }
    }
    return icons
  }

  func parseManifestURLs() -> [URL] {
    var urls: [URL] = []
    guard let document = document else {
      return []
    }
    for element in document.query(for: "/html/head/link") {
      guard let rel = element.attributes["rel"],
        rel == "manifest",
        let href = element.attributes["href"],
        let url = URL(string: href, relativeTo: baseURL) else {
          continue
      }
      urls.append(url)
    }
    return urls
  }

  func parseManifestIcons(jsonData: Data) -> [Icon] {
    var icons: [Icon] = []
    guard let manifest = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
      let iconDictionaries = manifest["icons"] as? [[String: String]] else {
      return icons
    }
    for iconDictionary in iconDictionaries {
      guard let src = iconDictionary["src"],
        let url = URL(string: src) else {
        continue
      }
      let iconSize: IconSize?
      if let sizeString = iconDictionary["sizes"] {
        iconSize = self.iconSize(from: sizeString)
      } else  {
        iconSize = nil
      }
      icons.append(Icon(url: url, type: .manifest,
                        size: iconSize,
                        mimeType: iconDictionary["type"]))
    }
    return icons
  }

  private func iconSize(from string: String) -> IconSize? {
    let array = string.components(separatedBy: "x")
    guard array.count == 2,
      let width = Int(array[0]),
      let height = Int(array[0]) else {
      return nil
    }
    return IconSize(width: width, height: height)
  }
}
