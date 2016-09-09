//
//  StatusBarViewController.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-03-13.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa

class StatusBarViewController: NSViewController {

    var isAutoChangeWallpaperOn = true
    var isDockIconOn = true
    var timerTask = NSTimer()
    
    let preferences = NSUserDefaults.standardUserDefaults()
    let pictureManager = PictureManager()

    @IBOutlet weak var isAutoChangeWallpaperOnSwitch: NSButton!
    @IBOutlet weak var isDockIconOnSwitch: NSButton!
    
    override func awakeFromNib() {
        self.isAutoChangeWallpaperOn = preferences.boolForKey("isAutoChangeWallpaperOn")
        self.isDockIconOn = preferences.boolForKey("isDockIconOn")
        
//        self.isAutoChangeWallpaperOnSwitch.state = self.isAutoChangeWallpaperOn ? 1 : 0
//        self.isDockIconOnSwitch.state = self.isDockIconOn ? 1 : 0
        
        resetTimerTask()
        resetDockIcon()
    }
    
    func refreshWallpaper() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: false)
            self.pictureManager.fetchPastWallpapers()
        })
    }
    
    func resetTimerTask() {
        if self.isAutoChangeWallpaperOn {
            self.timerTask = NSTimer.scheduledTimerWithTimeInterval(3600, target: self, selector: #selector(StatusBarViewController.refreshWallpaper), userInfo: nil, repeats: true)
        } else {
            self.timerTask.invalidate()
        }
    }
    
    func resetDockIcon() {
        if self.isDockIconOn {
            NSApp.setActivationPolicy(NSApplicationActivationPolicy.Regular)
        } else {
            NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
        }
    }
    
    @IBAction func about(sender: NSButton) {
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(self)
    }
    
    @IBAction func quit(sender: NSButton) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    @IBAction func today(sender: NSButton) {
        self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: true)
        self.refreshWallpaper()
    }
    
    @IBAction func logoClicked(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openFile(self.pictureManager.workDirectory)
    }
    
    @IBAction func toggleAutoChange(sender: NSButton) {
        self.isAutoChangeWallpaperOn = sender.state == 1 ? true : false
        self.preferences.setBool(self.isAutoChangeWallpaperOn, forKey: "isAutoChangeWallpaperOn")
        self.resetTimerTask()
    }
    
    @IBAction func toggleDockIcon(sender: NSButton) {
        self.isDockIconOn = sender.state == 1 ? true : false
        self.preferences.setBool(self.isDockIconOn, forKey: "isDockIconOn")
        self.resetDockIcon()
    }
    
}
