//
//  BingPictureManager.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-07-12.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa

class BingPictureManager {
    
    var pastWallpapersRange = 15
    var workDirectory = "\(NSHomeDirectory())/Pictures/BingPaper"
    
    let netRequest = NSMutableURLRequest()
    let fileManager = FileManager.default
    
    init() {
        netRequest.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
        netRequest.timeoutInterval = 15
        netRequest.httpMethod = "GET"
    }
    
    fileprivate func buildInfoPath(onDate: String, atRegion: String) -> String {
        return "\(workDirectory)/\(onDate)_\(atRegion).json"
    }
    
    fileprivate func buildImagePath(onDate: String, atRegion: String) -> String {
        return "\(workDirectory)/\(onDate)_\(atRegion).jpg"
    }
    
    fileprivate func checkAndCreateWorkDirectory() {
        try? fileManager.createDirectory(atPath: workDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    fileprivate func obtainWallpaper(atIndex: Int, atRegion: String) {
        let baseURL = "http://www.bing.com/HpImageArchive.aspx"
        netRequest.url = URL(string: "\(baseURL)?format=js&n=1&idx=\(atIndex)&mkt=\(atRegion)")

        let reponseData = try? NSURLConnection.sendSynchronousRequest(netRequest as URLRequest, returning: nil)
        
        if let dataValue = reponseData {
            let data = try? JSONSerialization.jsonObject(with: dataValue, options: []) as AnyObject
            
            if let objects = data?.value(forKey: "images") as? [NSObject] {
                if let startDateString = objects[0].value(forKey: "startdate") as? String,
                    let urlString = objects[0].value(forKey: "url") as? String {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMdd"
                    if let startDate = formatter.date(from: startDateString) {
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: startDate)
                        
                        let infoPath = buildInfoPath(onDate: dateString, atRegion: atRegion)
                        let imagePath = buildImagePath(onDate: dateString, atRegion: atRegion)
                        
                        if !fileManager.fileExists(atPath: infoPath) {
                            checkAndCreateWorkDirectory()
                            
                            try? dataValue.write(to: URL(fileURLWithPath: infoPath), options: [.atomic])
                        }
                        
                        if !fileManager.fileExists(atPath: imagePath) {
                            checkAndCreateWorkDirectory()
                            
                            if urlString.contains("http://") || urlString.contains("https://") {
                                netRequest.url = URL.init(string: urlString)
                            } else {
                                netRequest.url = URL.init(string: "https://www.bing.com\(urlString)")
                            }
                            
                            let imageResponData = try? NSURLConnection.sendSynchronousRequest(netRequest as URLRequest, returning: nil)
                            try? imageResponData?.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
                        }
                    }
                }
            }
        }
    }
    
    func fetchWallpapers(atRegin: String) {
        for index in -1...pastWallpapersRange {
            obtainWallpaper(atIndex: index, atRegion: atRegin)
        }
    }
    
    func fetchLastWallpaper(atRegin: String) {
        for index in -1...0 {
            obtainWallpaper(atIndex: index, atRegion: atRegin)
        }
    }
    
    func checkWallpaperExist(onDate: String, atRegion: String) -> Bool {
        if fileManager.fileExists(atPath: buildImagePath(onDate: onDate, atRegion: atRegion)) {
            return true
        }
        return false
    }
    
    func getWallpaperInfo(onDate: String, atRegion: String) -> (copyright: String, copyrightLink: String) {
        let jsonString = try? String.init(contentsOfFile: buildInfoPath(onDate: onDate, atRegion: atRegion))
        
        if let jsonData = jsonString?.data(using: String.Encoding.utf8) {
            let data = try? JSONSerialization.jsonObject(with: jsonData, options: []) as AnyObject
            
            if let objects = data?.value(forKey: "images") as? [NSObject] {
                if let copyrightString = objects[0].value(forKey: "copyright") as? String,
                    let copyrightLinkString = objects[0].value(forKey: "copyrightlink") as? String {
                    return (copyrightString, copyrightLinkString)
                }
            }
        }
        
        return ("", "")
    }
    
    func setWallpaper(onDate: String, atRegion: String) {
        if checkWallpaperExist(onDate: onDate, atRegion: atRegion) {
            if let screens = NSScreen.screens() {
                screens.forEach({ (screen) in
                    try? NSWorkspace.shared().setDesktopImageURL(
                        URL(fileURLWithPath: buildImagePath(onDate: onDate, atRegion: atRegion)),
                        for: screen,
                        options: [:]
                    )
                })
            }
        }
        
    }
}
