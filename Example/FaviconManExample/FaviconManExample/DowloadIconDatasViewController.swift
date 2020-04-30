//
// DowloadIconDatasViewController.swift
// FaviconManExample
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

import UIKit
import FaviconMan
import SafariServices

class DowloadIconDatasViewController: BaseViewController {

  private var iconDataDownloadResult: [IconData] = []

  override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    FaviconMan.fman.request(textField.text!)?
      .responseIconDatas { [weak self] result in
        guard let self = self else { return }
        var iconDataDownloadResult: [IconData] = []
        result.forEach {
          switch $0 {
          case .success(let result):
            iconDataDownloadResult.append(result)
          case .failure(let error):
            print(error)
          }
        }
        self.iconDataDownloadResult = iconDataDownloadResult
        self.tableView.reloadData()
    }
    return true
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iconDataDownloadResult.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    cell.textLabel?.text = iconDataDownloadResult[indexPath.row].url.absoluteString
    cell.textLabel?.numberOfLines = 0
    cell.imageView?.image = UIImage(data: iconDataDownloadResult[indexPath.row].data)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    defer {
      tableView.deselectRow(at: indexPath, animated: true)
    }
    let viewController = SFSafariViewController(url: iconDataDownloadResult[indexPath.row].url)
    present(viewController, animated: true)
  }
}
