//
//  ThemeManager.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

public class ThemeManager {
    
    static var tintColor: UIColor {
        if let color = UserDefaults.standard.color(forKey: "Centralis.TintColor") {
            return color
        }
        return UIColor(red: 0.753, green: 0.537, blue: 0.855, alpha: 1)
    }
        
    public static var backgroundColour: UIColor {
        return UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .systemGray6
            } else {
                return .white
            }
        })
    }
    
    public class func setTintColor(_ colour: UIColor?) {
        UserDefaults.standard.set(colour, forKey: "Centralis.TintColor")
        NotificationCenter.default.post(name: ThemeManager.ThemeUpdate, object: nil)
    }
    
    public static let ThemeUpdate = Notification.Name("Centralis.ThemeUpdate")
}

public extension UIColor {
    
    static var centralisTintColor: UIColor {
        ThemeManager.tintColor
    }
    
    static var centralisBackgroundColor: UIColor {
        ThemeManager.backgroundColour
    }
    
}
