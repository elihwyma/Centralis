//
//  ThemeManager.swift
//  Aemulo
//
//  Created by Andromeda on 09/04/2021.
//

import UIKit

final class ThemeManager {
    
    static var tintColor: UIColor = {
        if let color = UserDefaults.standard.color(forKey: "Centralis.TintColor") {
            return color
        }
        return UIColor(red: 0.753, green: 0.537, blue: 0.855, alpha: 1)
    }()
    
    class func setTintColor(_ colour: UIColor?) {
        UserDefaults.standard.set(colour, forKey: "Centralis.TintColor")
        if let colour = colour {
            tintColor = colour
        }
        NotificationCenter.default.post(name: ThemeManager.ThemeUpdate, object: nil)
    }
        
    static var secondaryBackgroundColour: UIColor {
        UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .systemGray6
            } else {
                return .white
            }
        })
    }
    
    static var backgroundColour: UIColor {
        UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .black
            } else {
                return .systemGray6
            }
        })
    }
    
    static let ThemeUpdate = Notification.Name("Aemulo.ThemeUpdate")
    
}

extension UIColor {
    
    static var tintColor: UIColor {
        ThemeManager.tintColor
    }
    
    static var backgroundColor: UIColor {
        ThemeManager.backgroundColour
    }
    
    static var secondaryBackgroundColor: UIColor {
        ThemeManager.secondaryBackgroundColour
    }
    
}
