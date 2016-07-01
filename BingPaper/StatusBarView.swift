//
//  StatusBarView.swift
//  BingPaper
//
//  Created by Peng Jingwen on 2015-03-13.
//  Copyright (c) 2015 Peng Jingwen. All rights reserved.
//

import Cocoa

class StatusBarView: NSView {
    
    private let image: NSImage
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    
    private var popoverTransiencyMonitor: AnyObject?
    
    init(image: NSImage, statusItem: NSStatusItem, popover: NSPopover){
        self.image = image
        self.statusItem = statusItem
        self.popover = popover
        
        self.popoverTransiencyMonitor = nil
        
        let thickness = NSStatusBar.systemStatusBar().thickness
        let rect = CGRectMake(0, 0, thickness, thickness)
        
        super.init(frame: rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(dirtyRect: NSRect){
        self.statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: false)

        let size = self.image.size
        let rect = CGRectMake(2, 2, size.width, size.height)
        
        self.image.drawInRect(rect)
    }
    
    override func mouseDown(theEvent: NSEvent){
        if (self.popoverTransiencyMonitor == nil) {
            
            self.popover.showRelativeToRect(self.frame, ofView: self, preferredEdge: NSRectEdge.MinY)
            
            self.popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(
                NSEventMask.LeftMouseUpMask, handler: { (event: NSEvent) -> Void in

                    NSEvent.removeMonitor(self.popoverTransiencyMonitor!)
                    self.popoverTransiencyMonitor = nil
                    self.popover.close()
            })
        } else {
            
            NSEvent.removeMonitor(self.popoverTransiencyMonitor!)
            self.popoverTransiencyMonitor = nil
            self.popover.close()
        }
    }
}