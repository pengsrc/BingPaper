//
//  Shared.swift
//  BingPaper
//
//  Created by Aspire on 2016-09-28.
//  Copyright © 2016 Peng Jingwen. All rights reserved.
//

import Cocoa

enum SharedPreferencesKey: String {
    case WillLaunchOnSystemStartup = "WillLaunchOnSystemStartup"
    case WillDisplayIconInDock = "WillDisplayIconInDock"
    case WillAutoDownloadNewImages = "WillAutoDownloadNewImages"
    case WillDownloadImagesOfAllRegions = "WillDownloadImagesOfAllRegions"
    case DownloadedImagesStoragePath = "DownloadedImagesStoragePath"
    case CurrentSelectedBingRegion = "CurrentSelectedBingRegion"
}

class Shared: NSObject {

}
