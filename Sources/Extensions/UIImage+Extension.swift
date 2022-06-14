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
import ImageIO
import ObjectiveC

private var closureKey: UInt = 0
private var debugKey: UInt = 1

public enum ImageType: String {
    case play
    case pause
    case disclosure
}

/// This extension provide a way to access image resources with in framework
internal extension UIImage {
    static func messageKitImageWith(type: ImageType) -> UIImage? {
        UIImage(named: type.rawValue, in: Bundle.messageKitAssetBundle, compatibleWith: nil)
    }
}

extension UIImageView: Attachable {

    @IBInspectable
    /// Adds a red bordered rectangle around any faces detected.
    public var debugFaceAware: Bool {
        set {
            set(newValue, forKey: &debugKey)
        } get {
            guard let debug = getAttach(forKey: &debugKey) as? Bool else {
                return false
            }
            return debug
        }
    }

    @IBInspectable
    /// Set this to true if you want to center the image on any detected faces.
    public var focusOnFaces: Bool {
        set {
            let image = self.image
            self.image = nil
            set(image: image, focusOnFaces: newValue)
        } get {
            return sublayer() != nil ? true : false
        }
    }

    public func set(image: UIImage?, focusOnFaces: Bool) {
        guard focusOnFaces == true else {
            self.removeImageLayer(image: image)
            return
        }
        setImageAndFocusOnFaces(image: image)
    }

    /// You can provide a closure here to receive a callback for when all face
    /// detection and image adjustments have been finished.
    public var didFocusOnFaces: (() -> Void)? {
        set {
            set(newValue, forKey: &closureKey)
        } get {
            return getAttach(forKey: &closureKey) as? (() -> Void)
        }
    }

    private func setImageAndFocusOnFaces(image: UIImage?) {
        DispatchQueue.global(qos: .default).async {
            guard let image = image else {
                return
            }

            let cImage = image.ciImage ?? CIImage(cgImage: image.cgImage!)

            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
            let features = detector!.features(in: cImage)

            if features.count > 0 {
                let imgSize = CGSize(width: Double(image.cgImage!.width), height: (Double(image.cgImage!.height)))
                self.applyFaceDetection(for: features, size: imgSize, image: image)
            } else {
                self.removeImageLayer(image: image)
            }
        }
    }

    private func applyFaceDetection(for features: [AnyObject], size: CGSize, image: UIImage) {
        var rect = features[0].bounds!
        rect.origin.y = size.height - rect.origin.y - rect.size.height
        var rightBorder = Double(rect.origin.x + rect.size.width)
        var bottomBorder = Double(rect.origin.y + rect.size.height)

        for feature in features[1..<features.count] {
            var oneRect = feature.bounds!
            oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height
            rect.origin.x = min(oneRect.origin.x, rect.origin.x)
            rect.origin.y = min(oneRect.origin.y, rect.origin.y)

            rightBorder = max(Double(oneRect.origin.x + oneRect.size.width), Double(rightBorder))
            bottomBorder = max(Double(oneRect.origin.y + oneRect.size.height), Double(bottomBorder))
        }

        rect.size.width = CGFloat(rightBorder) - rect.origin.x
        rect.size.height = CGFloat(bottomBorder) - rect.origin.y

        var center = CGPoint(x: rect.origin.x + rect.size.width / 2.0, y: rect.origin.y + rect.size.height / 2.0)
        var offset = CGPoint.zero
        var finalSize = size

        DispatchQueue.main.async {
            if size.width / size.height > self.bounds.size.width / self.bounds.size.height {
                finalSize.height = self.bounds.size.height
                finalSize.width = size.width / size.height * finalSize.height
                center.x = finalSize.width / size.width * center.x
                center.y = finalSize.width / size.width * center.y

                offset.x = center.x - self.bounds.size.width * 0.5
                if offset.x < 0 {
                    offset.x = 0
                } else if offset.x + self.bounds.size.width > finalSize.width {
                    offset.x = finalSize.width - self.bounds.size.width
                }
                offset.x = -offset.x
            } else {
                finalSize.width = self.bounds.size.width
                finalSize.height = size.height / size.width * finalSize.width
                center.x = finalSize.width / size.width * center.x
                center.y = finalSize.width / size.width * center.y

                offset.y = center.y - self.bounds.size.height * CGFloat(1 - 0.618)
                if offset.y < 0 {
                    offset.y = 0
                } else if offset.y + self.bounds.size.height > finalSize.height {
                    finalSize.height = self.bounds.size.height
                    offset.y = finalSize.height
                }
                offset.y = -offset.y
            }
        }

        var newImage: UIImage
        if self.debugFaceAware {
            // Draw rectangles around detected faces
            let rawImage = UIImage(cgImage: image.cgImage!)
            UIGraphicsBeginImageContext(size)
            rawImage.draw(at: CGPoint.zero)

            let context = UIGraphicsGetCurrentContext()
            context!.setStrokeColor(UIColor.red.cgColor)
            context!.setLineWidth(3)

            for feature in features[0..<features.count] {
                var faceViewBounds = feature.bounds!
                faceViewBounds.origin.y = size.height - faceViewBounds.origin.y - faceViewBounds.size.height

                context!.addRect(faceViewBounds)
                context!.drawPath(using: .stroke)
            }

            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        } else {
            newImage = image
        }

        DispatchQueue.main.sync {
            self.image = newImage

            let layer = self.imageLayer()
            layer.contents = newImage.cgImage
            layer.frame = CGRect(x: offset.x, y: offset.y, width: finalSize.width, height: finalSize.height)
            self.didFocusOnFaces?()
        }
    }

    private func imageLayer() -> CALayer {
        if let layer = sublayer() {
            return layer
        }

        let subLayer = CALayer()
        subLayer.name = "AspectFillFaceAware"
        subLayer.actions = ["contents": NSNull(), "bounds": NSNull(), "position": NSNull()]
        layer.addSublayer(subLayer)
        return subLayer
    }

    private func removeImageLayer(image: UIImage?) {
        DispatchQueue.main.async {
            // avoid redundant layer when focus on faces for the image of cell specified in UITableView
            self.imageLayer().removeFromSuperlayer()
            self.image = image
        }
    }

    private func sublayer() -> CALayer? {
        if let sublayers = layer.sublayers {
            for layer in sublayers where layer.name == "AspectFillFaceAware" {
                return layer
            }
        }
        return nil
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if focusOnFaces {
            setImageAndFocusOnFaces(image: self.image)
        }
    }
}

extension UIImage {
    class func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ]

        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
            else {
            return nil
        }

        return UIImage(cgImage: image)
    }

    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    class func resized(_ image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func colored(in color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.set()
            self.withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func imageWithSize(_ size: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }

}
