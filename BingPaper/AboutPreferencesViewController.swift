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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    init() {
        // NSApplication.shared().orderFrontStandardAboutPanel(self)
        super.init(nibName: "AboutPreferencesView", bundle: Bundle())!
        
        self.loadView()
        self.setup()
    }

    override var identifier: String? {
        get {
            return "About"
        }

        set {
            super.identifier = newValue
        }
    }

    var toolbarItemImage: NSImage! = #imageLiteral(resourceName: "Envolope")
    var toolbarItemLabel: String! = "About  "
    
    @IBOutlet weak var versionAndBuildString: NSTextField!

    func setup() {
        let prefixString = "\(NSLocalizedString("Version", comment: "N/A")): "
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let buildString = Bundle.main.infoDictionary?["CFBundleVersion"]
        
        self.versionAndBuildString.stringValue = "\(prefixString)\(versionString!) (\(buildString!))"
    }

    @IBAction func openEmail(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: "mailto:hi@pjw.io") as! URL)
    }
    
    @IBAction func openWebsite(_ sender: NSButton) {
        NSWorkspace.shared().open(NSURL(string: "https://pjw.io") as! URL)
    }
}
