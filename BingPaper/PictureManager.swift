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
    let fileManager = NSFileManager.defaultManager()
    
    override init() {
        self.netRequest.cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
        self.netRequest.timeoutInterval = 15
        self.netRequest.HTTPMethod = "GET"
        
        do {
            try self.fileManager.createDirectoryAtPath(self.workDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch _ {}
    }
    
    private func obtainWallpaperDateAndUrlAt(index index: Int) -> (Int, String) {
        
        self.netRequest.URL = NSURL(string: "http://www.bing.com/HpImageArchive.aspx?format=js&idx=\(index)&n=1&mkt=zh-CN")
        let reponseData = try? NSURLConnection.sendSynchronousRequest(self.netRequest, returningResponse: nil)
        if let dataValue = reponseData {
            var err: NSError?
            var dataObject: AnyObject?
            do {
                dataObject = try NSJSONSerialization.JSONObjectWithData(dataValue, options: NSJSONReadingOptions())
            } catch let error as NSError {
                err = error
                dataObject = nil
            };
            
            if err == nil {
                if let objects: AnyObject = dataObject?.valueForKey("images") {
                    if let dateString = objects[0].valueForKey("startdate") as? String {
                        if let urlString = objects[0].valueForKey("url") as? String {
                            if let dateNumber = Int(dateString) {
                                return (dateNumber, urlString)
                            }
                        }
                    }
                }
            }
        }

        return (0, "")
    }
    
    private func checkAndFetchWallpaperAt(index index: Int) {
        let wallpaper = self.obtainWallpaperDateAndUrlAt(index: index)
        if wallpaper.0 != 0 && !self.fileManager.fileExistsAtPath("\(self.workDirectory)/\(wallpaper.0).jpg") {
            self.netRequest.URL = NSURL.init(string: "https://www.bing.com\(wallpaper.1)")
            let imageResponData = try? NSURLConnection.sendSynchronousRequest(self.netRequest, returningResponse: nil)
            imageResponData?.writeToFile("\(self.workDirectory)/\(wallpaper.0).jpg", atomically: true)
        }
    }
    
    func fetchLastWallpaperAndSetAsWallpaper(forceUpdate forceUpdate: Bool) {
        let lastWallpaper = self.obtainWallpaperDateAndUrlAt(index: 0)
        
        if lastWallpaper.0 != 0 {
            let path = "\(self.workDirectory)/\(lastWallpaper.0).jpg"
            var updateFlag = false

            if !self.fileManager.fileExistsAtPath(path) {
                updateFlag = true
                
                self.checkAndFetchWallpaperAt(index: 0)
            }
            
            if updateFlag || forceUpdate {
                if let screens = NSScreen.screens() {
                    for screen in screens {
                        do {
                            try NSWorkspace.sharedWorkspace().setDesktopImageURL(
                                NSURL(fileURLWithPath: path),
                                forScreen: screen ,
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
