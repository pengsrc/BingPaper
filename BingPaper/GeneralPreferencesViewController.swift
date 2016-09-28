//
//  GeneralPreferencesViewController.swift
//  BingPaper
//
//  Created by Aspire on 2016-09-27.
//  Copyright © 2016 Peng Jingwen. All rights reserved.
//

import Cocoa
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
        
        self.regionSelectPopUp.selectItem(withTag: 2)
    }
    
    @IBAction func toggleLaunchOnSystemStartup(_ sender: NSButton) {
        self.standardDefaults.set(
            sender.state == 1 ? true : false,
            forKey: SharedPreferencesKey.WillLaunchOnSystemStartup.rawValue
        )
    }
    
    @IBAction func selectRegion_zh_CN(_ sender: NSMenuItem) {
        print(sender)
    }

}
