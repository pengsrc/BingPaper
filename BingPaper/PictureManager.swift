//
//  PicturesManager.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-07-12.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa

class PictureManager: NSObject {
    
    var pastWallpapersRange = 15
    
    let workDirectory = "\(NSHomeDirectory())/Pictures/BingPaper"
    let netRequest = NSMutableURLRequest()
    let fileManager = FileManager.default
    
    override init() {
        self.netRequest.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
        self.netRequest.timeoutInterval = 15
        self.netRequest.httpMethod = "GET"
        
        do {
            try self.fileManager.createDirectory(atPath: self.workDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch _ {}
    }
    
    fileprivate func obtainWallpaperDateAndUrlAt(index: Int) -> (Int, String) {
        
        self.netRequest.url = URL(string: "http://www.bing.com/HpImageArchive.aspx?format=js&idx=\(index)&n=1&mkt=zh-CN")
//        let reponseData = try? NSURLConnection.sendSynchronousRequest(self.netRequest as URLRequest, returning: nil)
//        if let dataValue = reponseData {
//            var err: NSError?
//            var dataObject: AnyObject?
//            do {
//                dataObject = try JSONSerialization.jsonObject(with: dataValue, options: JSONSerialization.ReadingOptions()) as AnyObject
//            } catch let error as NSError {
//                err = error
//                dataObject = nil
//            };
//            
//            if err == nil {
//                if let objects = dataObject?.value(forKey: "images") as! NSObject {
//                    if let dateString = objects[0].value(forKey: "startdate") as String {
//                        if let urlString = objects[0].value(forKey: "url") as String {
//                            if let dateNumber = Int(dateString) {
//                                return (dateNumber, urlString)
//                            }
//                        }
//                    }
//                }
//            }
//        }

        return (0, "")
    }
    
    fileprivate func checkAndFetchWallpaperAt(index: Int) {
        let wallpaper = self.obtainWallpaperDateAndUrlAt(index: index)
        if wallpaper.0 != 0 && !self.fileManager.fileExists(atPath: "\(self.workDirectory)/\(wallpaper.0).jpg") {
            self.netRequest.url = URL.init(string: "https://www.bing.com\(wallpaper.1)")
            let imageResponData = try? NSURLConnection.sendSynchronousRequest(self.netRequest as URLRequest, returning: nil)
            try? imageResponData?.write(to: URL(fileURLWithPath: "\(self.workDirectory)/\(wallpaper.0).jpg"), options: [.atomic])
        }
    }
    
    func fetchLastWallpaperAndSetAsWallpaper(forceUpdate: Bool) {
        let lastWallpaper = self.obtainWallpaperDateAndUrlAt(index: 0)
        
        if lastWallpaper.0 != 0 {
            let path = "\(self.workDirectory)/\(lastWallpaper.0).jpg"
            var updateFlag = false

            if !self.fileManager.fileExists(atPath: path) {
                updateFlag = true
                
                self.checkAndFetchWallpaperAt(index: 0)
            }
            
            if updateFlag || forceUpdate {
                if let screens = NSScreen.screens() {
                    for screen in screens {
                        do {
                            try NSWorkspace.shared().setDesktopImageURL(
                                URL(fileURLWithPath: path),
                                for: screen ,
                                options: [:])
                        } catch _ {
                        }
                    }
                }
            }
        }

        
        self.checkAndFetchWallpaperAt(index: 0)
    }
    
    func fetchPastWallpapers() {
        for i in 1...pastWallpapersRange {
            self.checkAndFetchWallpaperAt(index: i)
        }
    }
    
}
