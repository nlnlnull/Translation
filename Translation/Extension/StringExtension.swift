//
//  StringExtension.swift
//  Translation
//
//  Created by 侯猛 on 2020/7/17.
//  Copyright © 2020 侯猛. All rights reserved.
//

import Foundation

extension String {
    var id: String {
        matches(for: #"id([\s\S]*)\?"#, in: self).first ?? ""
    }
    var area: String {
        matches(for: #".com\/([\s\S]*)\/app"#, in: self).first ?? ""
    }
    
    
    func range(_ ofString: String? = nil) -> NSRange {
        guard let ofString = ofString else {
            return (self as NSString).range(of: self)
        }
        return (self as NSString).range(of: ofString)
    }
    
    //使用正则表达式替换
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    var time: String {
        pregReplace(pattern: "[a-zA-Z]", with: " ")
    }
}

func matches(for regex: String, in text: String) -> [String] {
    let regex = try! NSRegularExpression(pattern:regex, options: [])
    var results = [String]()

    regex.enumerateMatches(in: text, options: [], range: NSMakeRange(0, text.utf16.count)) { result, flags, stop in
        if let r = result?.range(at: 1), let range = Range(r, in: text) {
            results.append(String(text[range]))
        }
    }
    return results
}


