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

open class HeaderSizeCalculator: MessageSizeCalculator {
    
    var incomingMessageLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 12, right: 8)
    var outgoingMessageLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 12, right: 8)
    
    var messageLabelFont = UIFont(fontStyle: .graphikBold, size: 13.0)!
    
    func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }

    open override func messageContainerMaxWidth(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message, at: indexPath) - 20.0
        return maxWidth
    }
    
    open override func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message, at: indexPath)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        var extraHeight: CGFloat = 0.0
        switch message.kind {
        case .header(let text, let additionalHeight):
            attributedText = text
            extraHeight = additionalHeight
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth, for: message, withAdditionalHeight: extraHeight)
        
        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width -= messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical
        
        return messageContainerSize
    }
    
    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        attributes.messageLabelInsets = messageLabelInsets(for: message)
        attributes.messageLabelFont = messageLabelFont
        attributes.avatarSize = CGSize.zero
        
        switch message.kind {
        case .header(let text, _):
            guard !text.string.isEmpty else { return }
            guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
            attributes.messageLabelFont = font
        default:
            break
        }
    }
}
