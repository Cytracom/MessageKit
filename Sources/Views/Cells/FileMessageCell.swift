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

/// A subclass of `MessageContentCell` used to display file messages.
open class FileMessageCell: MessageContentCell {
    
    // MARK: - Properties
    
    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    /// The label used to display the message's text.
    open var messageLabel = MessageLabel()
    
    /// The View for displaying the file details
    open var detailsView: UIView = {
        let detailsWidth = UIScreen.main.bounds.width - 70.0
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: detailsWidth, height: 72.0))
        containerView.cornerRadius = 8.0
        containerView.borderColor = .messagingLightGray
        containerView.borderWidth = 1.0
        return containerView
    }()
    
    /// The image view display the media content.
    open var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    open var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(fontStyle: .graphikMedium, size: 14.0)
        title.numberOfLines = 1
        return title
    }()
    
    open var fileDetailsLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(fontStyle: .graphikRegular, size: 14.0)
        title.numberOfLines = 1
        return title
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
        imageView.image = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
        fileDetailsLabel.attributedText = nil
        fileDetailsLabel.text = nil
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        imageView.contentMode = .scaleAspectFit
        messageContainerView.addSubview(messageLabel)
        detailsView.addSubview(imageView)
        detailsView.addSubview(titleLabel)
        detailsView.addSubview(fileDetailsLabel)
        messageContainerView.addSubview(detailsView)
        setupConstraints()
    }
    
    /// Responsible for setting up the constraints of the cell's subviews.
    func setupConstraints() {
        messageLabel.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, right: messageContainerView.rightAnchor, topConstant: 0.0, leftConstant: 0.0)
        detailsView.addConstraints(messageLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, topConstant: 7.0, leftConstant: 4.0)
        let detailsWidth = UIScreen.main.bounds.width - 70.0
        detailsView.constraint(equalTo: CGSize(width: detailsWidth, height: 72.0))
        imageView.addConstraints(left: detailsView.leftAnchor, centerY: detailsView.centerYAnchor, leftConstant: 16.0, widthConstant: 32.0, heightConstant: 32.0)
        titleLabel.addConstraints(imageView.topAnchor, left: imageView.rightAnchor, right: detailsView.rightAnchor, leftConstant: 11.0, rightConstant: 4.0)
        fileDetailsLabel.addConstraints(left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: detailsView.rightAnchor, leftConstant: 11.0, rightConstant: 4.0)
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
            case .file(let text, _):
                messageLabel.formatMessage(text, mentionedFirstLastName: mentionedFirstLastName)
                messageLabel.font = UIFont(fontStyle: .graphikRegular, size: 14.0)!
            default:
                break
            }
        }
        
        switch message.kind {
        case .file(_, let media):
            imageView.image = media.image
            titleLabel.font = UIFont(fontStyle: .graphikMedium, size: 14.0)!
            titleLabel.text = media.media?.filename
            fileDetailsLabel.font = UIFont(fontStyle: .graphikRegular, size: 14.0)!
            if let fileMedia = media.media {
                let fileSize = Int64(fileMedia.file_size)
                let size = Units(bytes: fileSize).getReadableUnit()
                fileDetailsLabel.text = size
            }
        default: break
        }
    }

    /// Used to handle the cell's contentView's tap gesture.
    /// Return false when the contentView does not need to handle the gesture.
    open override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return messageLabel.handleGesture(touchPoint)
    }
}
