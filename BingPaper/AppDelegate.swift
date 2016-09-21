//
//  AppDelegate.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-03-13.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var popover: NSPopover!
    
    override func awakeFromNib(){

        let statusItem = NSStatusBar.system().statusItem(withLength: -1);
        
        statusItem.view = StatusBarView(
            image: NSImage(named: "StatusBarIcon")!,
            statusItem: statusItem, popover: self.popover
        )
    }
}
