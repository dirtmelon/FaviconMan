# FaviconMan

A man help you to fetch icons of URL.

## Requirements
- iOS 10.0+ 
- Xcode 11.0+
- Swift 5


## Installation

FaviconMan is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FaviconMan'
```

## Features
- Preferred settings size and preferred type.
- Scan <link>, <meta> tags to support different types of icon.
- Detect if `/favicon.ico` exists.
- Can choose to get URL or download data.
- Get single or multiple URLs.
- Download single or multiple data.
- Of course, you can also cancel the request.

## Usage Example

Fetch multiple urls with a URL:
```swift
FaviconMan.fman.request("https://www.apple.com")?
  .responseURLs(completionHandler: { [weak self] (result) in
    guard let self = self else { return }
    switch result {
    case .success(let icons):
      // handle icons: [Icon]
    case .failure(let error):
      // handle error: FMError
    }
})
```

Your also can only fetch single URL:

```swift
FaviconMan.fman.request("https://wwww.apple.com")?
  .responseURL(completionHandler: { (result) in
    switch result {
    case .success(let icons):
      // handle icons: Icon
    case .failure(let error):
      // handle error: FMError
    }
})
```

Download icon data with URL:
```swift
FaviconMan.fman.request(textField.text!)?
  .responseIconDatas { results in
    results.forEach {
      switch $0 {
      case .success(let iconData):
        // handle iconData: IconData
      case .failure(let error):
        // handle error: FMError
      }
    }
}
```

Download single data with URL:
```swift
FaviconMan.fman.request("textField.text!")?
  .responseIconData(completionHandler: { (result) in
    switch result {
    case .success(let iconData):
    // handle iconData: IconData
    case .failure(let error):
    // handle error: FMError
    }
  })
```

Cancel request:
```swift
let request: Request? = ...
request?.cancel()
```

## Author

dirtmelon, 0xffdirtmelon@gmail.com

## License

FaviconMan is available under the MIT license. See the LICENSE file for more info.
