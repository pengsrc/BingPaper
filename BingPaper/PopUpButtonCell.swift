//
//  PopUpButtonCell.swift
//  BingPaper
//
//  Created by Aspire on 2016-10-07.
//  Copyright © 2016年 Peng Jingwen. All rights reserved.
//

import Cocoa

class PopUpButtonCell: NSPopUpButtonCell {
    
    func selectItem(withValue: String) {
        for index in 0 ..< self.numberOfItems {
            if let menuItem = self.item(at: index) as? MenuItem? {
                if menuItem?.value ==  withValue {
                    self.selectItem(at: index)
                    
                    return
                }
            }
        }
    }
}
