//
//  AppDelegate.swift
//  BingPaper
//
//  Created by Jingwen Peng on 2015-03-13.
//  Copyright (c) 2015 Jingwen Peng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var popover: NSPopover!
    
    override func awakeFromNib(){
        
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);

        statusBarItem.view = StatusBarView(image: #imageLiteral(resourceName: "StatusBarIcon"), statusItem: statusBarItem, popover: self.popover)
    }
}
