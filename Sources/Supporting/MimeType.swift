/*
 MIT License

 Copyright (c) 2017-2020 MessageKit

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

import Foundation
import MobileCoreServices

class MimeType {
    // See: https://medium.com/@francishart/swift-how-to-determine-file-type-4c46fc2afce8
    // Also: http://blog.ablepear.com/2010/08/how-to-get-file-extension-for-mime-type.html
    // Reference: https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html
    // For info on Unmanaged: https://nshipster.com/unmanaged/
    static func mime(for fileExtension: String) -> String {
        guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil),
              let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI.takeUnretainedValue(), kUTTagClassMIMEType) else {
            return "application/octet-stream"
        }
        
        return String(mimeUTI.takeUnretainedValue())
    }
    
    private static func utTypeConformsTo(tagClass: CFString, identifier: String, conformTagClass: CFString) -> Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(tagClass, identifier as CFString, nil) else {
            return false
        }
        return UTTypeConformsTo(uti.takeUnretainedValue(), conformTagClass)
    }

    static func isImage(mime: String) -> Bool {
        return utTypeConformsTo(tagClass: kUTTagClassMIMEType, identifier: mime, conformTagClass: kUTTypeImage)
    }
    
    static func isAudio(fileExtension: String) -> Bool {
        return utTypeConformsTo(tagClass: kUTTagClassFilenameExtension, identifier: fileExtension, conformTagClass: kUTTypeAudio)
    }
}
