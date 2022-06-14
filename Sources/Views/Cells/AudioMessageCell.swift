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
import AVFoundation

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class AudioMessageCell: MessageContentCell {

    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    /// The label used to display the message's text.
    var messageLabel = MessageLabel()

    /// The play button view to display on audio messages.
    public lazy var playButton: UIButton = {
        let playButton = UIButton(type: .custom)
        let playImage = UIImage.messageKitImageWith(type: .play)
        let pauseImage = UIImage.messageKitImageWith(type: .pause)
        playButton.setImage(playImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.setImage(pauseImage?.withRenderingMode(.alwaysTemplate), for: .selected)
        playButton.setBackgroundColor(color: .globalTintColor, forState: .normal)
        playButton.setBackgroundColor(color: .globalTintColor, forState: .selected)
        playButton.setBackgroundColor(color: .globalTintColor, forState: .disabled)
        playButton.setBackgroundColor(color: .globalTintColor, forState: .highlighted)
        return playButton
    }()

    /// The time duration label to display on audio messages.
    public lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: CGRect.zero)
        durationLabel.textAlignment = .right
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.text = "0:00"
        return durationLabel
    }()

    public lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.isHidden = true
        return activityIndicatorView
    }()

    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        return progressView
    }()

    lazy var detailsView: UIView = {
        let detailsWidth = UIScreen.main.bounds.width - 70.0
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: detailsWidth, height: 72.0))
        containerView.cornerRadius = 8.0
        containerView.borderColor = .messagingLightGray
        containerView.borderWidth = 1.0
        return containerView
    }()

    var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont(fontStyle: .graphikMedium, size: 14.0)
        title.numberOfLines = 1
        return title
    }()
    
    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        playButton.constraint(equalTo: CGSize(width: 25, height: 25))
        messageLabel.addConstraints(messageContainerView.topAnchor, left: messageContainerView.leftAnchor, right: messageContainerView.rightAnchor, topConstant: 0.0, leftConstant: 0.0)
        detailsView.addConstraints(messageLabel.bottomAnchor, left: messageContainerView.leftAnchor, bottom: messageContainerView.bottomAnchor, topConstant: 7.0, leftConstant: 4.0)
        let detailsWidth = UIScreen.main.bounds.width - 70.0
        detailsView.constraint(equalTo: CGSize(width: detailsWidth, height: 72.0))
        playButton.addConstraints(detailsView.topAnchor, left: detailsView.leftAnchor, topConstant: 12.0, leftConstant: 12.0, widthConstant: 32.0, heightConstant: 32.0)
        titleLabel.addConstraints(playButton.topAnchor, left: playButton.rightAnchor, right: detailsView.rightAnchor, topConstant: 2.0, leftConstant: 11.0, rightConstant: 4.0)

        activityIndicatorView.addConstraints(centerY: playButton.centerYAnchor, centerX: playButton.centerXAnchor)
        durationLabel.addConstraints(right: messageContainerView.rightAnchor, centerY: messageContainerView.centerYAnchor, rightConstant: 15)
        progressView.addConstraints(left: playButton.rightAnchor, right: durationLabel.leftAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5, rightConstant: 5)
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if layoutAttributes is MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 16.0)
            messageLabel.textAlignment = .left
            messageLabel.frame = messageContainerView.bounds
        }
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(messageLabel)
        messageContainerView.addSubview(playButton)
        messageContainerView.addSubview(activityIndicatorView)
        messageContainerView.addSubview(durationLabel)
        messageContainerView.addSubview(progressView)
        messageContainerView.addSubview(titleLabel)
        messageContainerView.addSubview(detailsView)
        setupConstraints()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
        progressView.progress = 0
        playButton.isSelected = false
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
        durationLabel.text = "0:00"
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        // compute play button touch area, currently play button size is (25, 25) which is hardly touchable
        // add 10 px around current button frame and test the touch against this new frame
        let playButtonTouchArea = CGRect(playButton.frame.origin.x - 10.0, playButton.frame.origin.y - 10, playButton.frame.size.width + 20, playButton.frame.size.height + 20)
        let translateTouchLocation = convert(touchLocation, to: messageContainerView)
        if playButtonTouchArea.contains(translateTouchLocation) {
            delegate?.didTapPlayButton(in: self)
        } else {
            super.handleTapGesture(gesture)
        }
    }

    // MARK: - Configure Cell

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView, mentionedFirstLastName: [String], isInternal: Bool) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView, mentionedFirstLastName: mentionedFirstLastName, isInternal: isInternal)
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }

        let playButtonLeftConstraint = messageContainerView.constraints.filter { $0.identifier == "left" }.first
        let durationLabelRightConstraint = messageContainerView.constraints.filter { $0.identifier == "right" }.first

        if !dataSource.isFromCurrentSender(message: message) {
            playButtonLeftConstraint?.constant = 12
            durationLabelRightConstraint?.constant = -8
        } else {
            playButtonLeftConstraint?.constant = 5
            durationLabelRightConstraint?.constant = -15
        }

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
            case .audio(_, let text):
                messageLabel.formatMessage(text, mentionedFirstLastName: mentionedFirstLastName)
                messageLabel.font = UIFont(fontStyle: .graphikRegular, size: 14.0)!
            default:
                break
            }
        }

        let tintColor = displayDelegate.audioTintColor(for: message, at: indexPath, in: messagesCollectionView)
        playButton.imageView?.tintColor = tintColor
        durationLabel.textColor = tintColor
        progressView.tintColor = tintColor
        displayDelegate.configureAudioCell(self, message: message)

        if case let .audio(audioItem, _) = message.kind {
            titleLabel.font = UIFont(fontStyle: .graphikMedium, size: 14.0)!
            titleLabel.text = audioItem.url.lastPathComponent
            durationLabel.text = displayDelegate.audioProgressTextFormat(audioItem.duration, for: self, in: messagesCollectionView)
        }

    }
}
