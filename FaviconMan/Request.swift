//
//  Request.swift
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

public class Request {
  public typealias DownloadIconDatasCompletionHandler = ([Result<IconData, FMError>]) -> Void
  public let id: UUID
  public let url: URL
  public let preferredSize: IconSize?
  public let preferredIconType: IconType?
  private let underlyingQueue: DispatchQueue
  private var needToDowloadIconData: Bool = false
  private var parser: Parser?
  
  init(url: URL,
       underlyingQueue: DispatchQueue,
       preferredSize: IconSize?,
       preferredIconType: IconType?) {
    self.id = UUID()
    self.url = url
    self.underlyingQueue = underlyingQueue
    self.preferredSize = preferredSize
    self.preferredIconType = preferredIconType
  }
  
  /// Adds a handler to fetch icon urls, sorted by preferredSize and preferredIconType.
  /// - Parameter completionHandler: A clouser when finish fetch icon urls, only handle the first url.
  /// - Returns: The request.
  @discardableResult
  public func responseURL(completionHandler: @escaping (Result<Icon, FMError>) -> Void) -> Self {
    responseURLs { (result) in
      switch result {
      case .success(let icons):
        guard let icon = icons.first else {
          completionHandler(.failure(.noFaviconURL))
          return
        }
        completionHandler(.success(icon))
      case .failure(let error):
        completionHandler(.failure(error))
      }
    }
    return self
  }

  /// Adds a handler to fetch icon urls, sorted by preferredSize and preferredIconType.
  /// - Parameter completionHandler: A clouser when finish fetch icon urls
  /// - Returns: The request.
  @discardableResult
  public func responseURLs(completionHandler: @escaping (Result<[Icon], FMError>) -> Void) -> Self {
    underlyingQueue.async {
      var icons: [Icon] = []
      var fmError: FMError?

      // search for classic, eg: https://www.google.com/favicon.ico
      var classicRequest = URLRequest(url: URL(string: "/favicon.ico", relativeTo: self.url)!.absoluteURL)
      classicRequest.httpMethod = "HEAD"
      
      let classicDataOperation =
        FaviconMan.fman.operation(for: self,
                                  urlRequest: classicRequest) { (result) in
                                    if case .success(_) = result {
                                      icons.append(Icon(url: classicRequest.url!,
                                                        type: .classic))
                                    }
      }

      // download and scan html for icon
      var request = URLRequest(url: self.url)
      request.httpMethod = "GET"
      let dataOperation =
        FaviconMan.fman.operation(for: self,
                           urlRequest: request) { [weak self] (result) in
                            guard let self = self else { return }
                            switch result {
                            case .success(let(data, urlResponse)):
                              guard let data = data else {
                                fmError = FMError.dataNil
                                return
                              }
                              guard let url = urlResponse.url else {
                                fmError = FMError.responseURLNil
                                return
                              }
                              let parser = Parser(data: data, baseURL: url)
                              icons += parser.parseHTMLHeadLinkIcons() + parser.parseHTMLHeadMetaIcons()
                              self.parser = parser
                            case .failure(let error):
                              fmError = error
                            }
      }

      let finishOperation = BlockOperation { [weak self] in
        guard let self = self else { return }

        let queue = self.needToDowloadIconData ? self.underlyingQueue : .main
        queue.async {
          let result: Result<[Icon], FMError>
          if let error = fmError {
            result = .failure(error)
          } else {
            result = .success(Icon.sort(results: icons,
                                        preferredSize: self.preferredSize,
                                        preferredType: self.preferredIconType))
          }
          completionHandler(result)
        }
      }

      // manifest
      let manifestURLsOperation = BlockOperation { [weak self] in
        guard let self = self,
          let parser = self.parser else { return }
        let manifestURLs = parser.parseManifestURLs()
        for url in manifestURLs {
          let manifestURLdataOperation =
            FaviconMan.fman.operation(for: self,
                                      urlRequest: URLRequest(url: url)) { [weak self] (result) in
                                        guard let self = self else { return }
                                        switch result {
                                        case .success(let(data, _)):
                                          guard let data = data else {
                                            fmError = FMError.dataNil
                                            return
                                          }
                                          icons += self.parser?.parseManifestIcons(jsonData: data) ?? []
                                        case .failure(let error):
                                          fmError = error
                                        }
          }
          finishOperation.addDependency(manifestURLdataOperation)
          FaviconMan.fman.addOperations(for: self, operations: [manifestURLdataOperation])
        }
      }
      manifestURLsOperation.addDependency(dataOperation)

      finishOperation.addDependency(classicDataOperation)
      finishOperation.addDependency(dataOperation)
      finishOperation.addDependency(manifestURLsOperation)
      FaviconMan.fman.addOperations(for: self, operations: [classicDataOperation,
                                                            dataOperation,
                                                            manifestURLsOperation,
                                                            finishOperation])
    }
    return self
  }

  /// Adds a handler to download a icon data, sorted by preferredSize and preferredIconType.
  /// - Parameter completionHandler: A clouser when finish download icon data.
  /// - Returns: The request.
  @discardableResult
  public func responseIconData(completionHandler: @escaping (Result<IconData, FMError>) -> Void) -> Self {
    responseURL { [weak self] (result) in
      switch result {
      case .success(let icon):
        self?.downloadIconDatas(for: [icon],
                                completionHandler: { (results) in
                                  guard let result = results.first else {
                                    completionHandler(.failure(.dataNil))
                                    return
                                  }
                                  completionHandler(result)
        })
      case .failure(let error):
        completionHandler(.failure(error))
      }
    }
    return self
  }

  /// Adds a handler to download all icon datas, sorted by preferredSize and preferredIconType.
  /// - Parameter completionHandler: A clouser when finish download all icon datas.
  /// - Returns: The request.
  @discardableResult
  public func responseIconDatas(completionHandler: @escaping DownloadIconDatasCompletionHandler) -> Self {
    needToDowloadIconData = true
    responseURLs { [weak self] (result) in
      switch result {
      case .success(let icons):
        self?.downloadIconDatas(for: icons,
                                completionHandler: completionHandler)
      case .failure(let error):
        completionHandler([.failure(error)])
      }
    }
    return self
  }
  
  /// Cancel all task for the request.
  /// - Returns: The request
  @discardableResult
  public func cancel() -> Self {
    underlyingQueue.async {
      FaviconMan.fman.cancelOperations(for: self)
    }
    return self
  }

  private func downloadIconDatas(for icons: [Icon], completionHandler: @escaping DownloadIconDatasCompletionHandler) {
    var successResults: [IconData] = []
    var failureResults: [FMError] = []
    var dataTaskOperations: [DataTaskOperation] = []
    for icon in icons {
      let operation =
      FaviconMan.fman.operation(for: self,
                         urlRequest: URLRequest(url: icon.url)) { (result) in
                          switch result {
                          case .success(let (data, _)):
                            if let data = data {
                              successResults.append(IconData(data: data,
                                                             url: icon.url,
                                                             type: icon.type,
                                                             size: icon.size))
                            } else {
                              failureResults.append(.dataNil)
                            }
                          case .failure(let error):
                            failureResults.append(.dataTaskError(error: error))

                          }
      }
      dataTaskOperations.append(operation)
    }
    let finishOperation = BlockOperation { [weak self] in
      guard let self = self else { return }
      DispatchQueue.main.async {
        let results: [Result<IconData, FMError>] =
          IconData.sort(results: successResults,
                        preferredSize: self.preferredSize,
                        preferredType: self.preferredIconType).map { .success($0) } +
            failureResults.map { .failure($0) }

        completionHandler(results)
      }
    }
    dataTaskOperations.forEach { finishOperation.addDependency($0) }
    FaviconMan.fman.addOperations(for: self, operations: dataTaskOperations + [finishOperation])
  }
}

// MARK: - Equatable
extension Request: Equatable {
  public static func == (lhs: Request, rhs: Request) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: - Hashble
extension Request: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension URLResponse {
  var isHTTPStatusCodeOK: Bool {
    return (self as? HTTPURLResponse)?.statusCode == 200
  }
}
