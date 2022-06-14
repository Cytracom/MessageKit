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

import Foundation
import UIKit

internal extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }

    static let incomingGray = UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0)

    static let outgoingGreen = UIColor(red: 69/255, green: 214/255, blue: 93/255, alpha: 1.0)

    static let playButtonLightGray = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)

    private static func colorFromAssetBundle(named: String) -> UIColor {
        guard let color = UIColor(named: named, in: Bundle.messageKitAssetBundle, compatibleWith: nil) else {
            fatalError(MessageKitError.couldNotFindColorAsset)
        }
        return color
    }
    
    static var incomingMessageBackground: UIColor { colorFromAssetBundle(named: "incomingMessageBackground")  }

    static var outgoingMessageBackground: UIColor { colorFromAssetBundle(named: "outgoingMessageBackground") }
    
    static var incomingMessageLabel: UIColor { colorFromAssetBundle(named: "incomingMessageLabel") }
    
    static var outgoingMessageLabel: UIColor { colorFromAssetBundle(named: "outgoingMessageLabel") }
    
    static var incomingAudioMessageTint: UIColor { colorFromAssetBundle(named: "incomingAudioMessageTint") }
    
    static var outgoingAudioMessageTint: UIColor { colorFromAssetBundle(named: "outgoingAudioMessageTint") }

    static var collectionViewBackground: UIColor { colorFromAssetBundle(named: "collectionViewBackground") }

    static var typingIndicatorDot: UIColor { colorFromAssetBundle(named: "typingIndicatorDot") }
    
    static var label: UIColor { colorFromAssetBundle(named: "label") }
    
    static var avatarViewBackground: UIColor { colorFromAssetBundle(named: "avatarViewBackground") }

    static let smsGreen = UIColor(red:0.602, green:0.792, blue:0.377, alpha:1.000)
    static let c2cBlue = UIColor(red:0.005, green:0.458, blue:0.850, alpha:1.000)

    static let royalBlue = UIColor(netHex: 0x1E96FC)
    static let globalTintColor = UIColor(netHex: 0xE9E9EC)
    static let darkGrey = UIColor(netHex: 0x1E1F20)

    // MARK: - Messaging Colors
    static let messagingThreadBackgroundColor = UIColor(netHex: 0xFAFAFA)
    static let messagingLightGray = UIColor(netHex: 0x8F92A1)
    static let messagingPrivateChatModeEnabled = UIColor(netHex: 0xFBAB3D)
    static let internalMessageBackground = UIColor(netHex: 0xFAEAD4)
}
