//
//  Bundle+Extensions.swift
//  Centralis
//
//  Created by Andromeda on 26/11/2021.
//

import Foundation

extension Bundle {
    
    var iconFileName: String {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return "AppIcon" }
        return iconFileName
    }
    
}
