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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: "GeneralPreferencesView", bundle: Bundle())!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override var identifier: String? {
        get { return "General" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = #imageLiteral(resourceName: "Switch")
    var toolbarItemLabel: String! = NSLocalizedString("General", comment: "N/A")
}
