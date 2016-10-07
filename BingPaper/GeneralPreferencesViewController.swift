//
//  GeneralPreferencesViewController.swift
//  BingPaper
//
//  Created by Aspire on 2016-09-27.
//  Copyright © 2016 Peng Jingwen. All rights reserved.
//

import Cocoa
import ServiceManagement
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    override var identifier: String? {
        get { return "General" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = #imageLiteral(resourceName: "Switch")
    var toolbarItemLabel: String! = NSLocalizedString("General", comment: "N/A")
    
    @IBOutlet weak var autoStartCheckButton: NSButton!
    @IBOutlet weak var dockIconCheckButton: NSButton!
    @IBOutlet weak var autoDownloadCheckButton: NSButton!
    @IBOutlet weak var downloadAllRegionsCheckButton: NSButton!
    @IBOutlet weak var regionSelectPopUp: PopUpButtonCell!
    @IBOutlet weak var storagePathButton: NSButton!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: "GeneralPreferencesView", bundle: Bundle())!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadPreferences()
    }
    
    func loadPreferences() {
        self.autoStartCheckButton.state = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillLaunchOnSystemStartup
        ) ? 1 : 0
        
        self.dockIconCheckButton.state = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillDisplayIconInDock
        ) ? 1 : 0
        
        self.autoDownloadCheckButton.state = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillAutoDownloadNewImages
        ) ? 1 : 0
        
        self.downloadAllRegionsCheckButton.state = SharedPreferences.bool(
            forKey: SharedPreferences.Key.WillDownloadImagesOfAllRegions
        ) ? 1 : 0
        
        if let region = SharedPreferences.string(
            forKey: SharedPreferences.Key.CurrentSelectedBingRegion
        ) {
            self.regionSelectPopUp.selectItem(withValue: region)
        }
        
        if let storagePath = SharedPreferences.string(
            forKey: SharedPreferences.Key.DownloadedImagesStoragePath
        ) {
            self.storagePathButton.title = storagePath
        }
    }
    
    @IBAction func toggleLaunchOnSystemStartup(_ sender: NSButton) {
        let isEnabled = sender.state == 1 ? true : false

        SharedPreferences.set(
            isEnabled, forKey: SharedPreferences.Key.WillLaunchOnSystemStartup
        )
        
        SMLoginItemSetEnabled("com.prettyxw.mac.BingPaperLoginItem" as CFString, isEnabled)
    }
    
    @IBAction func toggleDockIcon(_ sender: NSButton) {
        let isOn = sender.state == 1 ? true : false
        
        SharedPreferences.set(
            isOn, forKey: SharedPreferences.Key.WillDisplayIconInDock
        )
        
        if isOn {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
    }
    
    @IBAction func toggleDownload(_ sender: NSButton) {
        let isEnabled = sender.state == 1 ? true : false
        
        SharedPreferences.set(isEnabled, forKey: SharedPreferences.Key.WillAutoDownloadNewImages)
    }
    
    @IBAction func toggleDownloadAll(_ sender: NSButton) {
        SharedPreferences.set(
            sender.state == 1 ? true : false,
            forKey: SharedPreferences.Key.WillDownloadImagesOfAllRegions
        )
    }
    
    @IBAction func selectRegion(_ sender: MenuItem) {
        if let value = sender.value {
            SharedPreferences.set(value, forKey: SharedPreferences.Key.CurrentSelectedBingRegion)
        }
    }
    
    @IBAction func viewStoragePath(_ sender: NSButton) {
        NSWorkspace.shared().openFile(self.storagePathButton.title)
    }
    
    @IBAction func changeStoragePath(_ sender: NSButton) {
        let openPanel = NSOpenPanel();
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false;
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            if response == NSModalResponseOK {
                if let path = openPanel.url?.path {
                    SharedPreferences.set(
                        path,
                        forKey: SharedPreferences.Key.DownloadedImagesStoragePath
                    )
                    
                    self.loadPreferences()
                }
            }
        }
    }
    
    @IBAction func resetPreferences(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Reset Warning", comment: "N/A")
        alert.informativeText = NSLocalizedString(
            "Are you sure to reset you would like to reset the preferences?",
            comment: "N/A"
        )
        alert.addButton(withTitle: NSLocalizedString("Reset", comment: "N/A"))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: "N/A"))
        alert.alertStyle = NSAlertStyle.warning
        
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) -> Void in
            if response == NSAlertFirstButtonReturn {
                SharedPreferences.clear()
                
                self.loadPreferences()
            }
        })
    }
}
