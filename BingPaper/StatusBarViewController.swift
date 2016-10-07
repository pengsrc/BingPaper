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
    let pictureManager = BingPictureManager()
    
    var preferencesWindowController: NSWindowController?

    @IBOutlet weak var isAutoChangeWallpaperOnSwitch: NSButton!
    @IBOutlet weak var isDockIconOnSwitch: NSButton!
    
    override func awakeFromNib() {
        if SharedPreferences.bool(forKey: SharedPreferences.Key.WillDisplayIconInDock) {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
        
        self.timerTask = Timer.scheduledTimer(
            timeInterval: 3600,
            target: self,
            selector: #selector(StatusBarViewController.refreshWallpaper),
            userInfo: nil,
            repeats: true
        )
    }
    
    func refreshWallpaper() {
        if SharedPreferences.bool(forKey: SharedPreferences.Key.WillAutoDownloadNewImages) {
            DispatchQueue.main.async(execute: { () -> Void in
                self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: false)
                self.pictureManager.fetchPastWallpapers()
            })
        }
    }
    
    @IBAction func today(_ sender: NSButton) {
        self.pictureManager.fetchLastWallpaperAndSetAsWallpaper(forceUpdate: true)
        self.refreshWallpaper()
    }
    
    @IBAction func logoClicked(_ sender: NSButton) {
        if let path = SharedPreferences.string(
            forKey: SharedPreferences.Key.DownloadedImagesStoragePath
        ) {
            NSWorkspace.shared().openFile(path)
        }
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
