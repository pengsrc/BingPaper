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
    
    var standardDefaults: UserDefaults! = UserDefaults.standard
    
    var reginTagMap: [String: Int]! = [
        BingRegion.China.rawValue: 1,
        BingRegion.USA.rawValue: 2,
        BingRegion.Japan.rawValue: 3
    ]
    
    @IBOutlet weak var autoStartCheckButton: NSButton!
    @IBOutlet weak var dockIconCheckButton: NSButton!
    @IBOutlet weak var autoDownloadCheckButton: NSButton!
    @IBOutlet weak var downloadAllRegionsCheckButton: NSButton!
    @IBOutlet weak var regionSelectPopUp: NSPopUpButtonCell!
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
        self.autoStartCheckButton.state = self.standardDefaults.bool(
            forKey: SharedPreferencesKey.WillLaunchOnSystemStartup.rawValue
        ) ? 1 : 0
        
        self.dockIconCheckButton.state = self.standardDefaults.bool(
            forKey: SharedPreferencesKey.WillDisplayIconInDock.rawValue
        ) ? 1 : 0
        
        self.autoDownloadCheckButton.state = self.standardDefaults.bool(
            forKey: SharedPreferencesKey.WillAutoDownloadNewImages.rawValue
        ) ? 1 : 0
        
        self.downloadAllRegionsCheckButton.state = self.standardDefaults.bool(
            forKey: SharedPreferencesKey.WillDownloadImagesOfAllRegions.rawValue
        ) ? 1 : 0
        
        if let region = self.standardDefaults.string(
            forKey: SharedPreferencesKey.CurrentSelectedBingRegion.rawValue
        ) {
            if let regionTag = self.reginTagMap[region] {
                self.regionSelectPopUp.selectItem(withTag: regionTag)
            }
        }
        
        if let storagePath = self.standardDefaults.string(
            forKey: SharedPreferencesKey.DownloadedImagesStoragePath.rawValue
        ) {
            self.storagePathButton.stringValue = storagePath
        }
    }
    
    @IBAction func toggleLaunchOnSystemStartup(_ sender: NSButton) {
        let isEnabled = sender.state == 1 ? true : false

        self.standardDefaults.set(
            isEnabled, forKey: SharedPreferencesKey.WillLaunchOnSystemStartup.rawValue
        )

        if SMLoginItemSetEnabled("com.prettyxw.mac.BingPaperLoginItem" as CFString, isEnabled) {
            
        } else {
            
        }
    }
    
    @IBAction func toggleDockIcon(_ sender: NSButton) {
        let isOn = sender.state == 1 ? true : false
        
        self.standardDefaults.set(
            isOn, forKey: SharedPreferencesKey.WillDisplayIconInDock.rawValue
        )
        
        if isOn {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            NSApplication.shared().setActivationPolicy(NSApplicationActivationPolicy.accessory)
            NSApplication.shared().activate(ignoringOtherApps: true)
        }
    }
    
    @IBAction func toggleDownload(_ sender: NSButton) {
        self.standardDefaults.set(
            sender.state == 1 ? true : false,
            forKey: SharedPreferencesKey.WillAutoDownloadNewImages.rawValue
        )
    }
    
    @IBAction func toggleDownloadAll(_ sender: NSButton) {
        self.standardDefaults.set(
            sender.state == 1 ? true : false,
            forKey: SharedPreferencesKey.WillDownloadImagesOfAllRegions.rawValue
        )
    }
    
    @IBAction func selectRegionChina(_ sender: NSMenuItem) {
        self.standardDefaults.set(
            BingRegion.China.rawValue,
            forKey: SharedPreferencesKey.CurrentSelectedBingRegion.rawValue
        )
    }

    @IBAction func selectRegionUSA(_ sender: NSMenuItem) {
        self.standardDefaults.set(
            BingRegion.USA.rawValue,
            forKey: SharedPreferencesKey.CurrentSelectedBingRegion.rawValue
        )
    }
 
    @IBAction func selectRegionJapan(_ sender: NSMenuItem) {
        self.standardDefaults.set(
            BingRegion.Japan.rawValue,
            forKey: SharedPreferencesKey.CurrentSelectedBingRegion.rawValue
        )
    }
    
    @IBAction func viewStoragePath(_ sender: NSButton) {
    }
    
    @IBAction func changeStoragePath(_ sender: NSButton) {
    }
    
    
    @IBAction func resetPreferences(_ sender: NSButton) {
    }
}
