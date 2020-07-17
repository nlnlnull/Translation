//
//  DictionaryExtension.swift
//  Translation
//
//  Created by 侯猛 on 2020/7/17.
//  Copyright © 2020 侯猛. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    func stringForKey(_ key: String) -> String? {
        let value = self[key]
        if let valueInt64 = value as? Int64 { // 是整型
            let number = NSNumber(value: valueInt64)
            let formatter = NumberFormatter()
            return formatter.string(from: number)
        } else if let valueInt = value as? Int {  // 是整型
            let number = NSNumber(value: valueInt)
            let formatter = NumberFormatter()
            return formatter.string(from: number)
        } else if let valueDouble = value as? Double { // 是浮点型
            return StringNumber(number: valueDouble)
        } else if let valueString = value as? String {
            return valueString
        } else {
            return nil
        }
    }
    
    func dictionaryForKey(_ key: String) -> [String: Any]? {
        guard let value = (self[key] as? [String: Any]) else { return nil }
        return value
    }
    
    func floatForKey(_ key: String) -> Double? {
        let value = self[key]
        if let valueInt = value as? Int { // 是整型
            return Double(valueInt)
        } else if let valueFloat = value as? Double { // 是浮点型
            return valueFloat
        } else if let valueString = value as? String {
            return Double(valueString)
        } else {
            return nil
        }
    }
    
    func intForKey(_ key: String) -> Int? {
        let value = self[key]
        if let valueInt = value as? Int { // 是整型
            return valueInt
        } else if let valueFloat = value as? Double { // 是浮点型
            return Int(valueFloat)
        } else if let valueString = value as? String {
            return Int(valueString)
        } else {
            return nil
        }
    }
    
    func boolForKey(_ key: String) -> Bool? {
        let value = self[key]
        if let valueInt = value as? Int { // 是整型
            return valueInt > 0
        } else if let valueBool = value as? Bool {
            return valueBool
        } else if let valueString = value as? String {
            return valueString == "true"
        } else {
            return nil
        }
    }
    
    func timeIntervalForKey(_ key: String) -> TimeInterval? {
        let value = self[key]
        if let valueInt = value as? Int64 { // 是整型
            return TimeInterval(valueInt)
        } else if let valueFloat = value as? Double { // 是浮点型
            return TimeInterval(Int(valueFloat))
        } else if let valueString = value as? String {
            return TimeInterval(Int(valueString) ?? 0)
        } else {
            return nil
        }
    }
    
    func toJsonString() -> String? {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("is not a valid json object")
            return nil
        }
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        let str = String(data:data!, encoding: String.Encoding.utf8)
        return str
    }
    
    func merge(_ otherDictionary: [String: Any]?) -> [String: Any] {
        guard let otherDictionary = otherDictionary else {
            return self
        }
        var newDictionary: [String: Any] = [:]
        for item in self {
            newDictionary[item.key] = item.value
        }
        for item in otherDictionary {
            newDictionary[item.key] = item.value
        }
        return newDictionary
    }
}
