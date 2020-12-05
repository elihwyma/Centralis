//
//  NSAttributedString+Extension.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

extension NSMutableAttributedString {
    func addPair(bold: String, normal: String) {
        let leftp = NSMutableParagraphStyle()
        leftp.alignment = .left
        let rightp = NSMutableParagraphStyle()
        rightp.alignment = .right
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .paragraphStyle: leftp
        ]
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .paragraphStyle: rightp
        ]
        
        let boldText = NSAttributedString(string: bold, attributes: boldAttributes)
        let normalText = NSAttributedString(string: normal, attributes: fontAttributes)
        self.append(boldText)
        self.append(normalText)
    }
}
