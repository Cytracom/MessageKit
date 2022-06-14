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

/// A protocol used to represent the data for a media message.
public protocol MediaItem {
    
    var message: Message? { get }
    
    var media: MessageMedia? { get }
    
    var threadId: String? { get }
    
    /// The url where the media is located.
    var url: URL? { get }
    
    /// The image.
    var image: UIImage? { get set }
    
    /// A placeholder image for when the image is obtained asychronously.
    var placeholderImage: UIImage { get }
    
    /// The size of the media item.
    var size: CGSize { get }
    
}
public struct ImageMediaItem: MediaItem {

    public var message: Message?
    public var media: MessageMedia?
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
    public var threadId: String?

    public init(image: UIImage? = nil, forMessage message: Message? = nil, onThread thread: String? = nil, withMedia media: MessageMedia? = nil, placeholderImage placeholder: UIImage? = nil) {
        self.image = image
        self.message = message
        self.media = media
        self.threadId = thread
        self.size = CGSize(width: 312, height: 57)
        if let media = media {
            if let mediaItemURL = URL(string: media.url) {
                self.url = mediaItemURL
                let mediaPathExtension = mediaItemURL.pathExtension
                let mimeType = MimeType.mime(for: mediaPathExtension)
                if mimeType.contains("application") {
                    self.size = CGSize(width: 120, height: 28)
                }
            }
        }
        if let placeholder = placeholder {
            self.placeholderImage = placeholder
        } else {
            let placeholderImage = UIImage(systemName: "photo.on.rectangle.angled")!
            self.placeholderImage = placeholderImage
        }
    }

}
