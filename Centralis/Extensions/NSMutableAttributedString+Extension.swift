//
//  NSAttributedString+Extension.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

extension NSMutableAttributedString {
    func addPair(bold: String, normal: String) {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
        
        let boldText = NSAttributedString(string: bold, attributes: boldAttributes)
        let normalText = NSAttributedString(string: normal, attributes: fontAttributes)
        self.append(boldText)
        self.append(normalText)
    }
    
    func addBoldColour(bold: String, colour: UIColor) {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: colour
        ]
   
        let boldText = NSAttributedString(string: bold, attributes: boldAttributes)
        self.append(boldText)
    }
}
