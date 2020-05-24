//
//  IconType.swift
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

public enum IconType: String {
  // unknown
  case unknown
  // classic type, eg: https://www.google.com/favicon.ico
  case classic
  // <link> rel = "icon"
  case normal = "icon"
  // <link> rel = "shortcut icon"
  case shortcut = "shortcut icon"
  // <link> rel = "apple-touch-icon"
  case appleTouch = "apple-touch-icon"
  // <link> rel = "apple-touch-icon-precomposed"
  case appleTouchIconPrecomposed = "apple-touch-icon-precomposed"
  // <meta> name = "msapplication-tileimage"
  case msapplicationTileImage = "msapplication-tileimage"
  // <meta> name = "msapplication-square70x70logo"
  case msapplicationSquare70x70logo = "msapplication-square70x70logo"
  // <meta> name = "msapplication-square150x150logo"
  case msapplicationSquare150x150logo = "msapplication-square150x150logo"
  // <meta> name = "msapplication-wide310x150logo"
  case msapplicationWide310x150logo = "msapplication-wide310x150logo"
  // <meta> name = "msapplication-square310x310logo"
  case msapplicationSquare310x310logo = "msapplication-square310x310logo"
  // <meta> property = "og:image"
  case openGraphImage
  // <link> name = "manifest",scan from src
  case manifest
}
