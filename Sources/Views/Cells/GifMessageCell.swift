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
import SwiftyGif

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class GifMessageCell: MessageContentCell {
    
    // MARK: - Properties
    
    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    /// The label used to display the message's text.
    var messageLabel = MessageLabel()
    
    var gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Methods
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if layoutAttributes is MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 16.0)
            messageLabel.textAlignment = .left
            messageLabel.frame = messageContainerView.bounds
        }
    }
    
    /// Responsible for setting up the constraints of the cell's subviews.
    func setupConstraints() {
        messageLabel.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, right: messageContainerView.rightAnchor, topConstant: 0.0, leftConstant: 0.0)
        let imageWidth = UIScreen.main.bounds.width - 70.0
        gifImageView.constraint(equalTo: CGSize(width: imageWidth, height: 72.0))
        gifImageView.addConstraints(messageLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, topConstant: 7.0, leftConstant: 4.0)
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(gifImageView)
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
        self.gifImageView.image = nil
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, mentionedFirstLastName: [String], isInternal: Bool) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView, mentionedFirstLastName: mentionedFirstLastName, isInternal: isInternal)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        messageLabel.configure {
            messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                messageLabel.setAttributes(attributes, detector: detector)
            }
            switch message.kind {
            case .gif(let text, _):
                messageLabel.formatMessage(text, mentionedFirstLastName: mentionedFirstLastName)
                messageLabel.font = UIFont(fontStyle: .graphikRegular, size: 14.0)!
            default:
                break
            }
        }
        switch message.kind {
        case .gif(_, let mediaItem):
            gifImageView.image = mediaItem.placeholderImage
            guard let media = mediaItem.media else { return }
            guard let mediaURL = URL(string: media.url) else { return }
            gifImageView.setGifFromURL(mediaURL)
        default:
            break
        }
        displayDelegate.configureMediaMessageImageView(gifImageView, for: message, at: indexPath, in: messagesCollectionView)
    }
}
