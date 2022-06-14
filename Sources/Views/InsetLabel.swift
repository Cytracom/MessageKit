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

open class InsetLabel: UILabel {

    open var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }

    open override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

}

open class InsetView: UIView {
    
    public let label = InsetLabel()
    open var lineOffset: CGFloat = 16.0
    open var lineHeight: CGFloat = 2.0
    open var lineColor = UIColor.darkGrey.withAlphaComponent(0.6)
    open var shouldDrawLine: Bool = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }
    
    convenience init() { self.init(frame: CGRect.zero) }
    
    open func initLabel() {
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        let lead = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: label, attribute: .leading, multiplier: 1, constant: 0)
        let trail = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: label, attribute: .trailing, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1, constant: 0)
        addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        addConstraints([lead, trail, centerX])
        isOpaque = false
    }
    
    open override func draw(_ rect: CGRect) {
        if shouldDrawLine {
            let lineWidth = label.frame.minX - rect.minX - lineOffset
            if lineWidth <= 0 { return }
            
            let lineLeft = UIBezierPath(rect: CGRect(rect.minX + lineOffset, rect.midY, lineWidth, 1))
            let lineRight = UIBezierPath(rect: CGRect(label.frame.maxX, rect.midY, lineWidth, 1))
            
            lineLeft.lineWidth = lineHeight
            lineColor.set()
//            lineLeft.stroke()
            lineLeft.fill()
            
            lineRight.lineWidth = lineHeight
            lineColor.set()
//            lineRight.stroke()
            lineRight.fill()
        }
    }
}
