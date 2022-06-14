/*
 MIT License

 Copyright (c) 2017-2022 MessageKit

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
import UIKit
import SwiftDate

open class MessageSizeCalculator: CellSizeCalculator {

    public init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }

    public var incomingAvatarSize = CGSize(width: 24, height: 24)
    public var outgoingAvatarSize = CGSize(width: 24, height: 24)

    public var incomingAvatarPosition = AvatarPosition(vertical: .messageLabelTop)
    public var outgoingAvatarPosition = AvatarPosition(vertical: .messageLabelTop)

    public var avatarLeadingTrailingPadding: CGFloat = 16.0

    public var incomingMessagePadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    public var outgoingMessagePadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

    public var incomingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: UIEdgeInsets(left: 42))
    public var outgoingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)

    public var incomingCellBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 42))
    public var outgoingCellBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingMessageTopLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 14.0, left: 42.0, bottom: 0.0, right: 0.0))
    public var outgoingMessageTopLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 42))
    public var outgoingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingAccessoryViewSize = CGSize.zero
    public var outgoingAccessoryViewSize = CGSize.zero

    public var incomingAccessoryViewPadding = HorizontalEdgeInsets.zero
    public var outgoingAccessoryViewPadding = HorizontalEdgeInsets.zero

    public var incomingAccessoryViewPosition: AccessoryPosition = .messageCenter
    public var outgoingAccessoryViewPosition: AccessoryPosition = .messageCenter

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.avatarSize = avatarSize(for: message, at: indexPath)
        attributes.avatarPosition = avatarPosition(for: message)
        attributes.avatarLeadingTrailingPadding = avatarLeadingTrailingPadding

        attributes.messageContainerPadding = messageContainerPadding(for: message)
        attributes.messageContainerSize = messageContainerSize(for: message, at: indexPath)
        attributes.cellTopLabelSize = cellTopLabelSize(for: message, at: indexPath)
        attributes.cellBottomLabelSize = cellBottomLabelSize(for: message, at: indexPath)
        attributes.messageTimeLabelSize = messageTimeLabelSize(for: message, at: indexPath)
        attributes.cellBottomLabelAlignment = cellBottomLabelAlignment(for: message)
        attributes.messageTopLabelSize = messageTopLabelSize(for: message, at: indexPath)
        attributes.messageTopLabelAlignment = messageTopLabelAlignment(for: message, at: indexPath)

        attributes.messageBottomLabelAlignment = messageBottomLabelAlignment(for: message, at: indexPath)
        attributes.messageBottomLabelSize = messageBottomLabelSize(for: message, at: indexPath)

        attributes.accessoryViewSize = accessoryViewSize(for: message)
        attributes.accessoryViewPadding = accessoryViewPadding(for: message)
        attributes.accessoryViewPosition = accessoryViewPosition(for: message)
    }

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(for: message, at: indexPath)
        guard (messagesLayout.itemWidth >= 0 && itemHeight >= 0) else { return .zero }
        return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
    }

    open func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {

        let messageContainerHeight = messageContainerSize(for: message, at: indexPath).height
        let cellBottomLabelHeight = cellBottomLabelSize(for: message, at: indexPath).height
        let messageBottomLabelHeight = messageBottomLabelSize(for: message, at: indexPath).height
        let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
        let messageTopLabelHeight = messageTopLabelSize(for: message, at: indexPath).height
        let messageVerticalPadding = messageContainerPadding(for: message).vertical + 10.0
        let avatarHeight = avatarSize(for: message, at: indexPath).height
        let avatarVerticalPosition = avatarPosition(for: message).vertical
        let accessoryViewHeight = accessoryViewSize(for: message).height

        switch avatarVerticalPosition {
        case .messageCenter:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
            + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            var cellHeight = max(avatarHeight, totalLabelHeight)
            if !isNextMessageSameSender(at: indexPath) || !isNextMessageSameDay(at: indexPath) || !isNextMessageWithin60Seconds(at: indexPath) {
                cellHeight = (cellHeight - avatarHeight) + 7.0
            }
            return max(cellHeight, accessoryViewHeight)
        case .messageBottom:
            var cellHeight: CGFloat = 0
            cellHeight += messageBottomLabelHeight
            cellHeight += cellBottomLabelHeight
            let labelsHeight = messageContainerHeight + messageVerticalPadding + cellTopLabelHeight + messageTopLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            cellHeight += messageTopLabelHeight
            let labelsHeight = messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight + 12.0
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageLabelTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            let messageLabelsHeight = messageContainerHeight + messageBottomLabelHeight + messageVerticalPadding + messageTopLabelHeight + cellBottomLabelHeight + 12.0
            cellHeight += max(messageLabelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .cellTop, .cellBottom:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
            + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight)
        }
    }

    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        let dataSource = messagesLayout.messagesDataSource
        let numberOfSections = dataSource.numberOfSections(in: messagesLayout.messagesCollectionView) - 1
        if indexPath.section + 1 <= numberOfSections {
            let cellToCheck = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
            let nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            return cellToCheck.sender.senderId == dataSource.messageForItem(at: nextIndexPath, in: messagesLayout.messagesCollectionView).sender.senderId
        }
        return false
    }

    private func isNextMessageSameDay(at indexPath: IndexPath) -> Bool {
        let dataSource = messagesLayout.messagesDataSource
        let numberOfSections = dataSource.numberOfSections(in: messagesLayout.messagesCollectionView) - 1
        if indexPath.section + 1 <= numberOfSections {
            let cellToCheck = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
            let nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            return cellToCheck.sentDate.compare(.isSameDay(dataSource.messageForItem(at: nextIndexPath, in: messagesLayout.messagesCollectionView).sentDate))
        }
        return false
    }

    private func isNextMessageWithin60Seconds(at indexPath: IndexPath) -> Bool {
        let dataSource = messagesLayout.messagesDataSource
        let numberOfSections = dataSource.numberOfSections(in: messagesLayout.messagesCollectionView) - 1
        if indexPath.section + 1 <= numberOfSections {
            let cellToCheck = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
            let nextIndexPath = IndexPath(row: 0, section: indexPath.section + 1)
            return cellToCheck.sentDate.compareCloseTo(dataSource.messageForItem(at: nextIndexPath, in: messagesLayout.messagesCollectionView).sentDate, precision: 1.minutes.timeInterval)
        }
        return false
    }
    // MARK: - Avatar

    open func avatarPosition(for message: MessageType) -> AvatarPosition {
        var position = incomingAvatarPosition // isFromCurrentSender ? outgoingAvatarPosition : incomingAvatarPosition

        switch position.horizontal {
        case .cellTrailing, .cellLeading:
            break
        case .natural:
            position.horizontal = .cellLeading
        }
        return position
    }

    open func avatarSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        return incomingAvatarSize
    }

    // MARK: - Top cell Label

    open func cellTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellTopLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func cellTopLabelAlignment(for message: MessageType) -> LabelAlignment {
        return incomingCellTopLabelAlignment
    }
    
    // MARK: - Top message Label

    open func messageTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageTopLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }
    
    open func messageTopLabelAlignment(for message: MessageType, at indexPath: IndexPath) -> LabelAlignment {
        return incomingMessageTopLabelAlignment
    }

    // MARK: - Message time label

    open func messageTimeLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        guard let attributedText = dataSource.messageTimestampLabelAttributedText(for: message, at: indexPath) else {
            return .zero
        }
        let size = attributedText.size()
        return CGSize(width: size.width, height: size.height)
    }

    // MARK: - Bottom cell Label
    
    open func cellBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }
    
    open func cellBottomLabelAlignment(for message: MessageType) -> LabelAlignment {
        return incomingCellBottomLabelAlignment
    }

    // MARK: - Bottom Message Label

    open func messageBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func messageBottomLabelAlignment(for message: MessageType, at indexPath: IndexPath) -> LabelAlignment {
        return incomingMessageBottomLabelAlignment
    }

    // MARK: - Accessory View

    public func accessoryViewSize(for message: MessageType) -> CGSize {
        return incomingAccessoryViewSize
    }

    public func accessoryViewPadding(for message: MessageType) -> HorizontalEdgeInsets {
        return incomingAccessoryViewPadding
    }
    
    public func accessoryViewPosition(for message: MessageType) -> AccessoryPosition {
        return incomingAccessoryViewPosition
    }

    // MARK: - MessageContainer

    open func messageContainerPadding(for message: MessageType) -> UIEdgeInsets {
        switch message.kind {
        case .header(_, _):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default: break
        }
        return incomingMessagePadding // isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
    }

    open func messageContainerSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        // Returns .zero by default
        return .zero
    }

    open func messageContainerMaxWidth(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        var startingWidth = messagesLayout.itemWidth
        switch message.kind {
        case .header(_, _):
            startingWidth += 0
            let messagePadding = messageContainerPadding(for: message)
            let accessoryWidth = accessoryViewSize(for: message).width
            let accessoryPadding = accessoryViewPadding(for: message)
            return startingWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal
        case .file(_, _), .photo(_, _), .gif(_, _):
            startingWidth += 0
        case .audio(_, _):
            startingWidth += 0
        default: break
        }
        let avatarWidth = avatarSize(for: message, at: indexPath).width
        let messagePadding = messageContainerPadding(for: message)
        let accessoryWidth = accessoryViewSize(for: message).width
        let accessoryPadding = accessoryViewPadding(for: message)
        return startingWidth - avatarWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal
    }

    // MARK: - Helpers

    public var messagesLayout: MessagesCollectionViewFlowLayout {
        guard let layout = layout as? MessagesCollectionViewFlowLayout else {
            fatalError("Layout object is missing or is not a MessagesCollectionViewFlowLayout")
        }
        return layout
    }

    func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat, for message: MessageType? = nil, withAdditionalHeight additionalHeight: CGFloat = 0.0) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
        if let message = message {
            switch message.kind {
            case .header(_, _):
                var height: CGFloat = 0.0
                if !attributedText.string.isEmpty {
                    height = rect.height + (rect.height * 0.95) + additionalHeight
                } else {
                    height = rect.height
                }
                let newRect = CGRect(x: 0.0, y: 0.0, width: maxWidth, height: height)
                return newRect.size
            case .file(let text, _), .photo(let text, _), .video(let text, _), .gif(let text, _):
                var height: CGFloat = 0.0
                if !text.isEmpty {
                    height = rect.height
                }
                let newRect = CGRect(x: 0.0, y: 0.0, width: rect.width, height: height)
                return newRect.size
            default: return rect.size
            }
        } else {
            return rect.size
        }
    }
}

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
