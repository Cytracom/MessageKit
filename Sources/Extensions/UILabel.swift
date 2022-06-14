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

extension UILabel {
    convenience init(text: String, style: UIFont.TextStyle) {
        self.init()
        switch style {
        case .caption1:
            font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        case .body:
            font = UIFont.boldSystemFont(ofSize: 18.0)
        default:
            font = UIFont.systemFont(ofSize: 14.0)
        }
        self.text = text
        textColor = .white
        backgroundColor = .clear
    }
    
    func startBlinking() {
        let options : UIView.AnimationOptions = [.repeat, .autoreverse]
        UIView.animate(withDuration: 0.25, delay:0.0, options:options, animations: {
            self.alpha = 0
        }, completion: nil)
    }
    
    func formatMessage(_ message: String, mentionedFirstLastName: [String]) {
        DispatchQueue.main.async {
            let mutableAttributedString = NSMutableAttributedString(string: message)
            let ranges = self.resolveHighlightedRanges(message, mentionedFirstLastName: mentionedFirstLastName)
            for range in ranges {
                if range.length > 0 {
                    mutableAttributedString.addAttributes([NSAttributedString.Key.backgroundColor: UIColor.messagingPrivateChatModeEnabled, NSAttributedString.Key.foregroundColor: UIColor.white], range: range)
                }
            }
            self.text = nil
            self.attributedText = mutableAttributedString
        }
    }
    
    private func resolveHighlightedRanges(_ message: String, mentionedFirstLastName: [String]) -> [NSRange] {
        var ranges: [NSRange] = []
        for mention in mentionedFirstLastName {
            guard let regex = try? NSRegularExpression(pattern: mention, options: []) else { return [] }
            let matches = regex.matches(in: message, options: [], range: NSRange(message.startIndex..<message.endIndex, in: message))
            ranges.append(contentsOf: matches.map{ $0.range })
        }

        return ranges
    }
}
