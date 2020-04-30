//
// DataTaskOperation.swift
// FaviconMan
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

class DataTaskOperation: Operation {

  var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
  private let request: URLRequest
  private weak var session: URLSession?
  private var dataTask: URLSessionDataTask?
  private var _isExecuting: Bool = false {
    willSet {
      willChangeValue(forKey: "isExecuting")
    }
    didSet {
      didChangeValue(forKey: "isExecuting")
    }
  }
  private var _isFinished: Bool = false {
    willSet {
      willChangeValue(forKey: "isFinished")
    }
    didSet {
      didChangeValue(forKey: "isFinished")
    }
  }
    
  override var isConcurrent: Bool {
    return true
  }
  
  override var isExecuting: Bool {
    return _isExecuting
  }
  
  override var isFinished: Bool {
    return _isFinished
  }

  init(request: URLRequest,
       session: URLSession) {
    self.request = request
    self.session = session
  }
  
  override func start() {
    guard !isCancelled else {
      _isFinished = true
      completionHandler?(nil, nil, FMError.cancelledBeforeStart)
      reset()
      return;
    }
    guard let session = session else { fatalError("Data task operation must has a session.") }
    dataTask = session.dataTask(with: request,
                                completionHandler: { [weak self] (data, response, error) in
                                  guard let self = self else { return }
                                  self.completionHandler?(data, response, error)
                                  self.done()
                                  
    })
    _isExecuting = true
    dataTask?.resume()
  }
  
  override func cancel() {
    guard !isFinished else {
      return
    }
    super.cancel()
    if isExecuting {
      _isExecuting = false
    }
    if !_isFinished {
      _isFinished = true
    }
    reset()
    
  }
  
  private func done() {
    _isFinished = true
    _isExecuting = false
    reset()
  }
  
  private func reset() {
    if let dataTask = dataTask {
      dataTask.cancel()
      self.dataTask = nil
    }
    session = nil
    completionHandler = nil
  }
}
