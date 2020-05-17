//
//  BingPictureManager.swift
//  BingPaper
//
//  Created by Jingwen Peng on 2015-07-12.
//  Copyright (c) 2015 Jingwen Peng. All rights reserved.
//

import Cocoa

class BingPictureManager {
    let netRequest = NSMutableURLRequest()
    let fileManager = FileManager.default
    
    var pastWallpapersRange = 15
    
    init() {
        netRequest.cachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy
        netRequest.timeoutInterval = 15
        netRequest.httpMethod = "GET"
    }
    
    fileprivate func buildInfoPath(workDir: String, onDate: String, atRegion: String) -> String {
        return "\(workDir)/\(onDate)_\(atRegion).json"
    }
    
    fileprivate func buildImagePath(workDir: String, onDate: String, atRegion: String) -> String {
        return "\(workDir)/\(onDate)_\(atRegion).jpg"
    }
    
    fileprivate func checkAndCreateWorkDirectory(workDir: String) {
        try? fileManager.createDirectory(atPath: workDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    fileprivate func obtainWallpaper(workDir: String, atIndex: Int, atRegion: String) {
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
                        
                        let infoPath = buildInfoPath(workDir: workDir, onDate: dateString, atRegion: atRegion)
                        let imagePath = buildImagePath(workDir: workDir, onDate: dateString, atRegion: atRegion)
                        
                        if !fileManager.fileExists(atPath: infoPath) {
                            checkAndCreateWorkDirectory(workDir: workDir)
                            
                            try? dataValue.write(to: URL(fileURLWithPath: infoPath), options: [.atomic])
                        }
                        
                        if !fileManager.fileExists(atPath: imagePath) {
                            checkAndCreateWorkDirectory(workDir: workDir)
                            
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
    
    func fetchWallpapers(workDir: String, atRegin: String) {
        for index in -1...pastWallpapersRange {
            obtainWallpaper(workDir: workDir, atIndex: index, atRegion: atRegin)
        }
    }
    
    func fetchLastWallpaper(workDir: String, atRegin: String) {
        for index in -1...0 {
            obtainWallpaper(workDir: workDir, atIndex: index, atRegion: atRegin)
        }
    }
    
    func checkWallpaperExist(workDir: String, onDate: String, atRegion: String) -> Bool {
        if fileManager.fileExists(atPath: buildImagePath(workDir: workDir, onDate: onDate, atRegion: atRegion)) {
            return true
        }
        return false
    }
    
    func getWallpaperInfo(workDir: String, onDate: String, atRegion: String) -> (copyright: String, copyrightLink: String) {
        let jsonString = try? String.init(contentsOfFile: buildInfoPath(workDir: workDir, onDate: onDate, atRegion: atRegion))
        
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
    
    func setWallpaper(workDir: String, onDate: String, atRegion: String) {
        if checkWallpaperExist(workDir: workDir, onDate: onDate, atRegion: atRegion) {
            NSScreen.screens.forEach({ (screen) in
                try? NSWorkspace.shared.setDesktopImageURL(
                    URL(fileURLWithPath: buildImagePath(workDir: workDir, onDate: onDate, atRegion: atRegion)),
                    for: screen,
                    options: [:]
                )
            })
        }
    }
}
