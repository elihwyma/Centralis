//
//  ColourConverter.swift
//  Centralis
//
//  Created by AW on 18/12/2020.
//

import CoreGraphics

///A class to convert a string to a UIColor, based on it's unicode scalar
internal class ColourConverter {
    
    /// Create a UIColor based on the input seed
    /// - Parameter seed: The string you want to convert
    /// - Returns: The resulting UIColor
    public func colourFromString(_ seed: String) -> CGColor {
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }
        
        srand48(total * 200)
        let r = CGFloat(drand48())
        
        srand48(total)
        let g = CGFloat(drand48())
        
        srand48(total / 200)
        let b = CGFloat(drand48())
        
        return CGColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }
}

