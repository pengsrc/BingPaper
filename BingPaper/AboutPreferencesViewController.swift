//
//  AboutPreferencesViewController.swift
//  BingPaper
//
//  Created by Aspire on 2016-09-27.
//  Copyright © 2016 Peng Jingwen. All rights reserved.
//

import Cocoa
import MASPreferences

class AboutPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    override var identifier: String? {
        get { return "About" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = #imageLiteral(resourceName: "Envolope")
    var toolbarItemLabel: String! = NSLocalizedString("About", comment: "N/A")
    
    @IBOutlet weak var versionAndBuildString: NSTextField!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(nibName: "AboutPreferencesView", bundle: Bundle())!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStrings()
    }

    func loadStrings() {
        let prefix = "\(NSLocalizedString("Version", comment: "N/A")): "
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let build = Bundle.main.infoDictionary?["CFBundleVersion"]
        
        versionAndBuildString.stringValue = "\(prefix)\(version!) (\(build!))"
    }

    @IBAction func openEmail(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: "mailto:hi@pjw.io") as! URL)
    }
    
    @IBAction func openWebsite(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: "https://pjw.io") as! URL)
    }
}
