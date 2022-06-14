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
import Kingfisher

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class MediaMessageCell: MessageContentCell {

    /// The play button view to display on video messages.
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        playButtonView.isHidden = true
        return playButtonView
    }()

    // MARK: - Properties
    
    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }
    
    /// The label used to display the message's text.
    var messageLabel = MessageLabel()
    
    /// The image view display the media content.
    open var imageView: UIImageView = {
        let detailsWidth = UIScreen.main.bounds.width - 70.0
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: detailsWidth, height: 72.0))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // MARK: - Methods
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if layoutAttributes is MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 16.0)
            messageLabel.textAlignment = .left
            messageLabel.frame = messageContainerView.bounds
        }
    }
    
    /// Responsible for setting up the constraints of the cell's subviews.
    func setupConstraints() {
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
        messageLabel.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, right: messageContainerView.rightAnchor, topConstant: 0.0, leftConstant: 0.0)
        let imageWidth = UIScreen.main.bounds.width - 70.0
        imageView.constraint(equalTo: CGSize(width: imageWidth, height: 72.0))
        imageView.addConstraints(messageLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, topConstant: 7.0, leftConstant: 0.0)
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(imageView)
        imageView.addSubview(playButtonView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6.0
        imageView.clipsToBounds = true
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
        self.imageView.image = nil
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
            case .photo(let text, _), .video(let text, _):
                messageLabel.formatMessage(text, mentionedFirstLastName: mentionedFirstLastName)
                messageLabel.font = UIFont(fontStyle: .graphikRegular, size: 14.0)!
            default:
                break
            }
        }
        switch message.kind {
        case .photo(_, var mediaItem):
            if mediaItem.image == nil {
                imageView.image = mediaItem.placeholderImage
                DispatchQueue.main.async {
                    if let photoURL = mediaItem.url {
                        DispatchQueue.main.async {
                            let processor = DownsamplingImageProcessor(size: self.imageView.bounds.size)
                            self.imageView.kf.indicatorType = .activity
                            self.imageView.kf.setImage(
                                with: URL(string: photoURL.absoluteString),
                                options: [
                                    .processor(processor),
                                    .scaleFactor(UIScreen.main.scale),
                                    .transition(.fade(1)),
                                    .cacheOriginalImage
                                ], completionHandler:
                                    {
                                        result in
                                        switch result {
                                        case .success(let value):
                                            mediaItem.image = value.image
                                        case .failure(_):
                                            if let message = mediaItem.message {
                                                self.getThumbnailImage(forMediaItem: mediaItem, forMessage: message)
                                            } else {
                                                self.getThumbnailImage(forMediaItem: mediaItem)
                                            }
                                        }
                                    })
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageView.image = mediaItem.image ?? mediaItem.placeholderImage
                        }
                    }
                }
            } else {
                imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            }
        case .video(_, let mediaItem):
            if let message = mediaItem.message {
                getThumbnailImage(forMediaItem: mediaItem, forMessage: message)
            } else {
                getThumbnailImage(forMediaItem: mediaItem)
            }
        default:
            break
        }
        displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
    }
    
    private func getThumbnailImage(forMediaItem mediaItem: MediaItem, forMessage message: Message? = nil) {
        guard let media = mediaItem.message else { return }
        if let thumbnailMedia = media.media.filter({ $0.file_ext != "smil" }).first {
            DispatchQueue.main.async {
                self.imageView.kf.cancelDownloadTask()
                let processor = DownsamplingImageProcessor(size: self.imageView.bounds.size)
                self.imageView.kf.indicatorType = .activity
                self.imageView.kf.setImage(
                    with: URL(string: thumbnailMedia.thumbnail_url),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ], completionHandler:
                        {
                            result in
                            switch result {
                            case .success(_):
                                break
                            case .failure(_):
                                self.imageView.image = mediaItem.placeholderImage
                            }
                        })
            }
        }
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: imageView)

        guard imageView.frame.contains(touchLocation) else {
            super.handleTapGesture(gesture)
            return
        }
        delegate?.didTapImage(in: self)
    }
    
}
