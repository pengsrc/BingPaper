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
    
    var previousDateString = ""
    var currentDateString = ""
    var nextDateString = ""
    var wallpaperInfoUrlString = ""
    
    var preferencesWindowController: NSWindowController?
    
    @IBOutlet weak var previousDayButton: NSButton!
    @IBOutlet weak var todayButton: NSButton!
    @IBOutlet weak var nextDayButton: NSButton!
    
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var wallpaperInfoButton: NSButton!
    
    
    override func awakeFromNib() {
        setupDockIcon()
        setupTimerTask()
        setupBingPictureManager()
        
        if let currentDate = SharedPreferences.string(forKey: SharedPreferences.Key.CurrentSelectedImageDate) {
            _ = jumpToDate(currentDate)
        } else {
            jumpToToday()
        }
        
        downloadWallpapers()
    }
    
    func setupDockIcon() {
        if SharedPreferences.bool(forKey: SharedPreferences.Key.WillDisplayIconInDock) {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
    }
    
    func setupTimerTask() {
        timerTask = Timer.scheduledTimer(
            timeInterval: 3600,
            target: self,
            selector: #selector(StatusBarViewController.downloadWallpapers),
            userInfo: nil,
            repeats: true
        )
    }
    
    func setupBingPictureManager() {
        if let workDirectory = SharedPreferences.string(forKey: SharedPreferences.Key.DownloadedImagesStoragePath) {
            bingPictureManager.workDirectory = workDirectory
        }
    }
    
    func downloadWallpapers() {
        let willDownload = SharedPreferences.bool(forKey: SharedPreferences.Key.WillAutoDownloadNewImages)
        let willChangeWallpaper = SharedPreferences.bool(forKey: SharedPreferences.Key.WillAutoChangeWallpaper)
        let isAllRegion = SharedPreferences.bool(forKey: SharedPreferences.Key.WillDownloadImagesOfAllRegions)
        let currentRegion = SharedPreferences.string(forKey: SharedPreferences.Key.CurrentSelectedBingRegion)
        
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
                } else {
                    _ = self.jumpToDate(self.currentDateString)
                }
            }
        }
    }
    
    func jumpToDate(_ date: String) -> Bool {
        if let region = SharedPreferences.string(forKey: SharedPreferences.Key.CurrentSelectedBingRegion) {
            
            if bingPictureManager.checkWallpaperExist(onDate: date, atRegion: region) {
                let info = bingPictureManager.getWallpaperInfo(onDate: date, atRegion: region)
                var infoString = info.copyright
                infoString = infoString.replacingOccurrences(of: ",", with: "\n")
                infoString = infoString.replacingOccurrences(of: "(", with: "\n")
                infoString = infoString.replacingOccurrences(of: ")", with: "")
                
                wallpaperInfoButton.title = infoString
                wallpaperInfoUrlString = info.copyrightLink
                
                currentDateString = date
                dateTextField.stringValue = date
                SharedPreferences.set(date, forKey: SharedPreferences.Key.CurrentSelectedImageDate)
                
                bingPictureManager.setWallpaper(onDate: date, atRegion: region)
                
                let searchLimit = 365
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if let date = formatter.date(from: date) {
                    previousDayButton.isEnabled = false
                    for index in 1...searchLimit {
                        let timeInterval = TimeInterval(-3600 * 24 * index)
                        let anotherDay = date.addingTimeInterval(timeInterval)
                        let anotherDayString = formatter.string(from: anotherDay)
                        
                        if bingPictureManager.checkWallpaperExist(onDate: anotherDayString, atRegion: region) {
                            previousDateString = anotherDayString
                            previousDayButton.isEnabled = true
                            
                            break
                        }
                    }
                }
                
                if let date = formatter.date(from: date) {
                    nextDayButton.isEnabled = false
                    for index in 1...searchLimit {
                        let timeInterval = TimeInterval(3600 * 24 * index)
                        let anotherDay = date.addingTimeInterval(timeInterval)
                        let anotherDayString = formatter.string(from: anotherDay)
                        
                        if bingPictureManager.checkWallpaperExist(onDate: anotherDayString, atRegion: region) {
                            nextDateString = anotherDayString
                            nextDayButton.isEnabled = true
                            
                            break
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
            self.todayButton.title = NSLocalizedString("Fetching...", comment: "N/A")
            
            if let currentRegion = SharedPreferences.string(forKey: SharedPreferences.Key.CurrentSelectedBingRegion) {
                self.bingPictureManager.fetchLastWallpaper(atRegin: currentRegion)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            _ = self.jumpToDate(formatter.string(from: Date()))
            
            self.todayButton.isEnabled = true
            self.todayButton.title = NSLocalizedString("Today !", comment: "N/A")
        }
    }
    
    @IBAction func logoClicked(_ sender: NSButton) {
        if let path = SharedPreferences.string(forKey: SharedPreferences.Key.DownloadedImagesStoragePath) {
            NSWorkspace.shared().openFile(path)
        }
    }
    
    @IBAction func previousDay(_ sender: NSButton) {
        _ = jumpToDate(previousDateString)
    }
    
    @IBAction func today(_ sender: NSButton) {
        jumpToToday()
    }
    
    @IBAction func nextDay(_ sender: NSButton) {
        _ = jumpToDate(nextDateString)
    }

    @IBAction func wallpaperInfoButtonClicked(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: wallpaperInfoUrlString) as! URL)
    }
    
    @IBAction func launchPreferencesWindow(_ sender: NSButton) {
        if (preferencesWindowController == nil) {
            preferencesWindowController = MASPreferencesWindowController.init(
                viewControllers: [GeneralPreferencesViewController(), AboutPreferencesViewController()],
                title: NSLocalizedString("BingPaper Preferences", comment: "N/A")
            )
        }
        
        preferencesWindowController?.showWindow(self)
        preferencesWindowController?.window?.makeKeyAndOrderFront(self)
        
        NSApplication.shared().activate(ignoringOtherApps: true)
    }
    
    @IBAction func quitApplication(_ sender: NSButton) {
        NSApplication.shared().terminate(nil)
    }
    
}
