//
//  FaviconMan.swift
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

open class FaviconMan {

  /// Shared singleton instance
  public static let fman = FaviconMan()
  /// Preferred icon size, used for all `Request`s by this instance, nil by default.
  /// Preferred icon size can also be set on a per-`Request` basis, in which case the `Request`'s preferredSize takes precedence over this value.
  public let preferredSize: IconSize?
  /// Preferred icon type, used for all `Request`s by this instance, nil by default.
  /// Preferred icon type can also be set on a per-`Request` basis, in which case the `Request`'s preferredIconType takes precedence over this value.
  public let preferredIconType: IconType?
  /// Underlying queue for all internal operations, must be a serial queue.
  public let underlyingQueue: DispatchQueue
  /// Underlying `URLSession` used to create `URLSessionTasks` for this instance
  public let session: URLSession
  /// Internal map between `Request` and all `URLSessionDataTask` that may be in flight for them.
  private var requestOperations: [Request: [Operation]] = [:]
  
  private let operationQueue: OperationQueue
  
  /// Creates a FaviconMan from a URLSession and other parameters
  /// - Parameters:
  ///   - session: Underlying `URLSession` for this instance.
  ///   - underlyingQueue: Underlying queue for this instance.
  ///   - preferredSize: `IconSize`, used for all `Request`s by this instance, nil by default.
  ///   - preferredIconType: `IconType`, used for all `Request`s by this instance, nil by default.
  init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default),
       underlyingQueue: DispatchQueue = DispatchQueue(label: "com.dirtmelon.faviconman.requestQueue"),
       preferredSize: IconSize? = nil,
       preferredIconType: IconType? = nil) {
    operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 6
    operationQueue.name = "com.dirtmelon.faviconman"
    self.session = session
    self.underlyingQueue = underlyingQueue
    self.preferredSize = preferredSize
    self.preferredIconType = preferredIconType
  }

  
  /// Creates a `Request` from `URLConvertible` value and other paramters.
  /// - Parameters:
  ///   - convertible: `URLConvertible` value to be used to create the `Request`
  ///   - preferredSize: `IconSize` value to be used to create the `Request`, nil by default.
  ///   - preferredIconType: `IconType` value to be used to create the `Request`, nil by default.
  /// - Returns: Return nil when the `convertible`'s `asURL()` return nil.
  @discardableResult
  public func request(_ convertible: URLConvertible,
                      preferredSize: IconSize? = nil,
                      preferredIconType: IconType? = nil) -> Request? {
    guard let url = convertible.asURL() else { return nil }
    let request = Request(url: url,
                          underlyingQueue: underlyingQueue,
                          preferredSize: preferredSize ?? self.preferredSize,
                          preferredIconType: preferredIconType ?? self.preferredIconType)
    return request
  }

  func operation(for request: Request,
                 urlRequest: URLRequest,
                 completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTaskOperation {
    let operation = DataTaskOperation(request: urlRequest,
                                          session: self.session)
    operation.completionHandler = completionHandler
    return operation
  }
  
  func cancelOperations(for request: Request) {
    defer {
      requestOperations.removeValue(forKey: request)
    }
    guard let operations = requestOperations[request] else {
      return
    }
    operations.forEach { $0.cancel()  }
  }
  
  func addOperations(for request: Request, operations: [Operation]) {
    
    for operation in operations {
      operation.completionBlock = { [weak self, weak operation] in
        guard let self = self,
          let operation = operation else { return }
        self.underlyingQueue.async {
          self.removeOperation(for: request, operation: operation)
        }
      }
    }
    requestOperations[request] = operations
    operationQueue.addOperations(operations, waitUntilFinished: false)
  }

  private func removeOperation(for request: Request, operation: Operation) {
    guard let index = requestOperations[request]?.firstIndex(of: operation) else { return }
    requestOperations[request]?.remove(at: index)
    guard requestOperations[request]?.isEmpty ?? true else {
      return
    }
    requestOperations.removeValue(forKey: request)
  }
}
