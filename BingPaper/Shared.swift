//
//  Shared.swift
//  BingPaper
//
//  Created by Aspire on 2016-09-28.
//  Copyright © 2016 Peng Jingwen. All rights reserved.
//

import Cocoa

class SharedBingRegion {
    
    static let China = "zh-CN"
    static let USA = "en-US"
    static let Japan = "ja-JP"
    
    static let All = [SharedBingRegion.China, SharedBingRegion.USA, SharedBingRegion.Japan]
}

class SharedPreferences {
    
    class Key {
        static let WillLaunchOnSystemStartup = "WillLaunchOnSystemStartup"
        static let WillDisplayIconInDock = "WillDisplayIconInDock"
        static let WillAutoDownloadNewImages = "WillAutoDownloadNewImages"
        static let WillAutoChangeWallpaper = "WillAutoChangeWallpaper"
        static let WillDownloadImagesOfAllRegions = "WillDownloadImagesOfAllRegions"
        static let DownloadedImagesStoragePath = "DownloadedImagesStoragePath"
        static let CurrentSelectedBingRegion = "CurrentSelectedBingRegion"
        static let CurrentSelectedImageDate = "CurrentSelectedImageDate"
    }
    
    class Defaults : NSObject {
        static let DownloadedImagesStoragePath = "\(NSHomeDirectory())/Pictures/BingPaper"
        static let CurrentSelectedBingRegion = SharedBingRegion.China
    }

    static func bool(forKey: String) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey)
    }
    
    static func boolInt(forKey: String) -> Int {
        return bool(forKey: forKey) ? 1 : 0
    }
    
    static func set(_ value: Bool, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
    }
    
    static func string(forKey: String) -> String? {
        if let value = UserDefaults.standard.string(forKey: forKey) {
            return value
        }
        
        if Defaults.responds(to: Selector(forKey)) {
            if let optionalValue = Defaults.value(forKey: forKey) as? String? {
                if let value = optionalValue {
                    return value
                }
            }
        }
        
        return nil
    }
    
    static func set(_ value: String, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
    }
    
    static func clear() {
        for item in UserDefaults.standard.dictionaryRepresentation() {
            UserDefaults.standard.removeObject(forKey: item.key)
        }
    }
}


