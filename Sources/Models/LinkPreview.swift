//
//  File.swift
//  
//
//  Created by Nathan Stoltenberg on 6/20/22.
//

import UIKit
public struct LinkPreview: LinkItem {
    public let text: String?
    public let attributedText: NSAttributedString?
    public let url: URL
    public let title: String?
    public let teaser: String
    public let thumbnailImage: UIImage
}
