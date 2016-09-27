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
        super.init(nibName: "AboutPreferencesView", bundle: Bundle())!
    }
    
    override var identifier: String? {
        get {
            return "About"
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage! = NSImage.init(named: "Envolope")
    var toolbarItemLabel: String! = "About  "
}
