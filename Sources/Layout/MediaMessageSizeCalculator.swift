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

open class MediaMessageSizeCalculator: MessageSizeCalculator {
    
    var messageLabelInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 4)

    func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        return messageLabelInsets
    }
    
    open override func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message, at: indexPath)
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        switch message.kind {
        case .gif(let text, _), .photo(let text, _), .video(let text, _):
            attributedText = NSAttributedString(string: text, attributes: [.font: UIFont(fontStyle: .graphikRegular, size: 14.0)!])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth, for: message)
        messageContainerSize = CGSize(width: maxWidth, height: messageContainerSize.height)
        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical + 64.0
        return messageContainerSize
    }
}
