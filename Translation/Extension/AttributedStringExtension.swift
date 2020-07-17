//
//  AttributedStringExtension.swift
//  Translation
//
//  Created by 侯猛 on 2020/7/17.
//  Copyright © 2020 侯猛. All rights reserved.
//

import Cocoa

extension NSMutableAttributedString {
    func addAttributeColor(_ color: NSColor?, rangeString: String? = nil) {
        guard let color = color else {
            return
        }
        self.addAttribute(.foregroundColor, value: color, range: range(rangeString))
    }
    func addAttributeFont(_ font: NSFont?, rangeString: String? = nil) {
        guard let font = font else {
            return
        }
        self.addAttribute(.font, value: font, range: range(rangeString))
    }
    func addAttribute(_ attrs: [NSAttributedString.Key : Any], rangeString: String? = nil) {
        self.addAttributes(attrs, range: range(rangeString))
    }
    
    func range(_ ofString: String? = nil) -> NSRange {
        return self.string.range(ofString)
    }
    
    func textSize(size: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude) , _ font: NSFont, _ lineSpacing: CGFloat = 0) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing // 段落高度
        let attributes = NSMutableAttributedString(string: string)
        attributes.addAttribute(.font, value: font, range: range())
        attributes.addAttribute(.paragraphStyle, value: paragraphStyle, range: range())
        let attSize = attributes.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        return attSize
    }

    
}

