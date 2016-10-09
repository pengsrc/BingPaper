//
//  StatusBarViewController.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-03-13.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa
import MASPreferences

class StatusBarViewController: NSViewController {
    var timerTask = Timer()
    var bingPictureManager = BingPictureManager()
    
    var yesterdayDate = ""
    var tomorrowDate = ""
    var wallpaperInfoUrl = ""
    
    var preferencesWindowController: NSWindowController?
    
    @IBOutlet weak var yesterdayButton: NSButton!
    @IBOutlet weak var todayButton: NSButton!
    @IBOutlet weak var tomorrowButton: NSButton!
    
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var wallpaperInfoButton: NSButton!
    
    
    override func awakeFromNib() {
        self.setupDockIcon()
        self.setupTimerTask()
        self.downloadWallpapers()
        
        if let currentDate = SharedPreferences.string(
            forKey: SharedPreferences.Key.CurrentSelectedImageDate
        ) {
            _ = self.jumpToDate(currentDate)
        } else {
            self.jumpToToday()
        }
    }
    
    func setupBingPictureManager() {
        if let workDirectory = SharedPreferences.string(
            forKey: SharedPreferences.Key.DownloadedImagesStoragePath
        ) {
            self.bingPictureManager.workDirectory = workDirectory
        }
    }
    
    func setupDockIcon() {
        if SharedPreferences.bool(forKey: SharedPreferences.Key.WillDisplayIconInDock) {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
    }
    
    func setupTimerTask() {
        self.timerTask = Timer.scheduledTimer(
            timeInterval: 3600,
            target: self,
            selector: #selector(StatusBarViewController.downloadWallpapers),
            userInfo: nil,
            repeats: true
        )
    }
    
    func downloadWallpapers() {
        let willDownload = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillAutoDownloadNewImages
        )
        let willChangeWallpaper = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillAutoChangeWallpaper
        )
        let isAllRegion = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillDownloadImagesOfAllRegions
        )
        let currentRegion = SharedPreferences.string(
            forKey: SharedPreferences.Key.CurrentSelectedBingRegion
        )
        
        if willDownload {
            DispatchQueue.global().async {
                var regions: [String] = []
                
                if isAllRegion {
                    regions = SharedBingRegion.All
                } else {
                    if let region = currentRegion {
                        regions.append(region)
                    }
                }
                
                for region in regions {
                    self.bingPictureManager.fetchWallpapers(atRegin: region)
                }
                
                if willChangeWallpaper {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    _ = self.jumpToDate(formatter.string(from: Date()))
                }
            }
        }
    }
    
    func jumpToDate(_ date: String) -> Bool {
        if let region = SharedPreferences.string(
            forKey: SharedPreferences.Key.CurrentSelectedBingRegion
            ) {
            
            if self.bingPictureManager.checkWallpaperExist(onDate: date, atRegion: region) {
                self.bingPictureManager.setWallpaper(onDate: date, atRegion: region)
                self.dateTextField.stringValue = date
                
                let info = self.bingPictureManager.getWallpaperInfo(onDate: date, atRegion: region)
                var infoString = info.copyright
                infoString = infoString.replacingOccurrences(of: ",", with: "\n")
                infoString = infoString.replacingOccurrences(of: "(", with: "\n")
                infoString = infoString.replacingOccurrences(of: ")", with: "")
                self.wallpaperInfoButton.title = infoString
                self.wallpaperInfoUrl = info.copyrightLink
                
                SharedPreferences.set(date, forKey: SharedPreferences.Key.CurrentSelectedImageDate)
                
                let searchLimit = 365
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if let date = formatter.date(from: date) {
                    self.yesterdayButton.isEnabled = false
                    for index in 1...searchLimit {
                        let timeInterval = TimeInterval(-3600 * 24 * index)
                        let yesterdayDate = date.addingTimeInterval(timeInterval)
                        let yesterdayDateString = formatter.string(from: yesterdayDate)
                        
                        if self.bingPictureManager.checkWallpaperExist(
                            onDate: yesterdayDateString, atRegion: region
                        ) {
                            self.yesterdayDate = yesterdayDateString
                            self.yesterdayButton.isEnabled = true
                        }
                    }
                }
                
                if let date = formatter.date(from: date) {
                    self.tomorrowButton.isEnabled = false
                    for index in 1...searchLimit {
                        let timeInterval = TimeInterval(3600 * 24 * index)
                        let tomorrowDate = date.addingTimeInterval(timeInterval)
                        let tomorrowDateStrint = formatter.string(from: tomorrowDate)
                        
                        if self.bingPictureManager.checkWallpaperExist(
                            onDate: tomorrowDateStrint, atRegion: region
                            ) {
                            self.tomorrowDate = tomorrowDateStrint
                            self.tomorrowButton.isEnabled = true
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func jumpToToday() {
        DispatchQueue.global().async {
            self.todayButton.isEnabled = false
            
            if let currentRegion = SharedPreferences.string(
                forKey: SharedPreferences.Key.CurrentSelectedBingRegion
                ) {
                self.bingPictureManager.fetchLastWallpaper(atRegin: currentRegion)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            _ = self.jumpToDate(formatter.string(from: Date()))
            
            self.todayButton.isEnabled = true
        }
    }
    
    @IBAction func logoClicked(_ sender: NSButton) {
        if let path = SharedPreferences.string(
            forKey: SharedPreferences.Key.DownloadedImagesStoragePath
            ) {
            NSWorkspace.shared().openFile(path)
        }
    }
    
    @IBAction func yesterday(_ sender: NSButton) {
        _ = self.jumpToDate(self.yesterdayDate)
    }
    
    @IBAction func today(_ sender: NSButton) {
        self.jumpToToday()
    }
    
    @IBAction func tomorrow(_ sender: NSButton) {
        _ = self.jumpToDate(self.tomorrowDate)
    }

    @IBAction func wallpaperInfoButtonClicked(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: self.wallpaperInfoUrl) as! URL)
    }
    
    @IBAction func launchPreferencesWindow(_ sender: NSButton) {
        if (self.preferencesWindowController == nil) {
            self.preferencesWindowController = MASPreferencesWindowController.init(
                viewControllers: [GeneralPreferencesViewController(), AboutPreferencesViewController()],
                title: NSLocalizedString("BingPaper Preferences", comment: "N/A")
            )
        }
        
        self.preferencesWindowController?.showWindow(self)
        self.preferencesWindowController?.window?.makeKeyAndOrderFront(self)
        
        NSApplication.shared().activate(ignoringOtherApps: true)
    }
    
    @IBAction func quitApplication(_ sender: NSButton) {
        NSApplication.shared().terminate(nil)
    }
    
}
