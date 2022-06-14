/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

public enum FontStyle: String {
    case graphikLightItalic = "Graphik-LightItalic"
    case graphikRegular = "Graphik-Regular"
    case graphikSuperItalic = "Graphik-SuperItalic"
    case graphikMedium = "Graphik-Medium"
    case graphikMediumItalic = "Graphik-MediumItalic"
    case graphikRegularItalic = "Graphik-RegularItalic"
    case graphikThinItalic = "Graphik-ThinItalic"
    case graphikSuper = "Graphik-Super"
    case graphikExtraLight = "Graphik-ExtraLight"
    case graphikBoldItalic = "Graphik-BoldItalic"
    case graphikBlackItalic = "Graphik-BlackItalic"
    case graphikBlack = "Graphik-Black"
    case graphikBold = "Graphik-Bold"
    case graphikSemibold = "Graphik-Semibold"
    case graphikExtraLightItalic = "Graphik-ExtraLightItalic"
    case graphikLight = "Graphik-Light"
    case graphikSemiboldItalic = "Graphik-SemiboldItalic"
    case graphikThin = "Graphik-Thin"
}

extension UIFont {
    public convenience init?(fontStyle: FontStyle, size: CGFloat) {
        self.init(name: fontStyle.rawValue, size: size)
    }
}
