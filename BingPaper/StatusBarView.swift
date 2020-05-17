//
//  StatusBarView.swift
//  BingPaper
//
//  Created by Jingwen Peng on 2015-03-13.
//  Copyright (c) 2015 Jingwen Peng. All rights reserved.
//

import Cocoa

class StatusBarView: NSView {

    fileprivate var image: NSImage
    fileprivate var statusItem: NSStatusItem
    fileprivate var popover: NSPopover
    
    fileprivate var popoverTransiencyMonitor: AnyObject?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(image: NSImage, statusItem: NSStatusItem, popover: NSPopover){
        self.image = image
        self.statusItem = statusItem
        self.popover = popover
        
        popoverTransiencyMonitor = nil
        
        let thickness = NSStatusBar.system.thickness
        let rect = CGRect(x: 0, y: 0, width: thickness, height: thickness)
        
        super.init(frame: rect)
    }
    
    override func draw(_ dirtyRect: NSRect){
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: false)

        let size = image.size
        let rect = CGRect(x: 2, y: 2, width: size.width, height: size.height)
        
        image.draw(in: rect)
    }
    
    override func mouseDown(with theEvent: NSEvent){
        if (popoverTransiencyMonitor == nil) {
            popover.show(relativeTo: frame, of: self, preferredEdge: NSRectEdge.minY)
            
            popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEvents(
                matching: NSEvent.EventTypeMask.leftMouseUp, handler: { (event: NSEvent) -> Void in
                    NSEvent.removeMonitor(self.popoverTransiencyMonitor!)
                    self.popoverTransiencyMonitor = nil
                    self.popover.close()
            }) as AnyObject?
        } else {
            NSEvent.removeMonitor(popoverTransiencyMonitor!)
            popoverTransiencyMonitor = nil
            popover.close()
        }
    }
}
