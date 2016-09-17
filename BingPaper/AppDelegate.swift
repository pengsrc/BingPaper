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

    var windowController: NSWindowController?
    
    override func awakeFromNib(){

        let statusItem = NSStatusBar.system().statusItem(withLength: -1);
        
        statusItem.view = StatusBarView(image: NSImage(named: "StatusBarIcon")!, statusItem: statusItem, popover: self.popover)
        
        // test()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let storyboard = NSStoryboard.init(name: "Storyboard", bundle: nil)
        let controller = storyboard.instantiateInitialController()
        
        if let windowController = controller as? NSWindowController {
            self.windowController = windowController
            
            windowController.loadWindow()
            windowController.showWindow(self)
            windowController.window?.makeKeyAndOrderFront(self)
            
            NSApplication.shared().activate(ignoringOtherApps: true)
            
            print(controller)
        }
    }
    
    func test() {
        
        NSApplication.shared().terminate(nil)
    }
}
