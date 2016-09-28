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

    var isAutoChangeWallpaperOn = true
    var isDockIconOn = true
    var timerTask = Timer()
    
    let preferences = UserDefaults.standard
    let pictureManager = BingPictureManager()
    
    var preferencesWindowController: NSWindowController?

    @IBOutlet weak var isAutoChangeWallpaperOnSwitch: NSButton!
    @IBOutlet weak var isDockIconOnSwitch: NSButton!
    
    override func awakeFromNib() {
        self.isAutoChangeWallpaperOn = preferences.bool(forKey: "isAutoChangeWallpaperOn")
        self.isDockIconOn = preferences.bool(forKey: "isDockIconOn")
        
//        self.isAutoChangeWallpaperOnSwitch.state = self.isAutoChangeWallpaperOn ? 1 : 0
//        self.isDockIconOnSwitch.state = self.isDockIconOn ? 1 : 0
        
        resetTimerTask()
        resetDockIcon()
    }
    
    func refreshWallpaper() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: false)
            self.pictureManager.fetchPastWallpapers()
        })
    }
    
    func resetTimerTask() {
        if self.isAutoChangeWallpaperOn {
            self.timerTask = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(StatusBarViewController.refreshWallpaper), userInfo: nil, repeats: true)
        } else {
            self.timerTask.invalidate()
        }
    }
    
    func resetDockIcon() {
        if self.isDockIconOn {
            NSApp.setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApp.setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
    }
    
    @IBAction func today(_ sender: NSButton) {
        self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: true)
        self.refreshWallpaper()
    }
    
    @IBAction func logoClicked(_ sender: NSButton) {
        NSWorkspace.shared().openFile(self.pictureManager.workDirectory)
    }
    
//    @IBAction func toggleAutoChange(sender: NSButton) {
//        self.isAutoChangeWallpaperOn = sender.state == 1 ? true : false
//        self.preferences.setBool(self.isAutoChangeWallpaperOn, forKey: "isAutoChangeWallpaperOn")
//        self.resetTimerTask()
//    }
//    
//    @IBAction func toggleDockIcon(sender: NSButton) {
//        self.isDockIconOn = sender.state == 1 ? true : false
//        self.preferences.setBool(self.isDockIconOn, forKey: "isDockIconOn")
//        self.resetDockIcon()
//    }
    
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
