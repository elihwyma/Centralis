//
//  CateringCell.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import UIKit

class TextViewCell: UITableViewCell {

    @IBOutlet weak var transactionsView: UITextView!
    var att: NSMutableAttributedString?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func addPair(bold: String, normal: String) {
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        let boldText = NSAttributedString(string: bold, attributes: boldAttributes)
        let normalText = NSAttributedString(string: normal, attributes: fontAttributes)
        self.att?.append(boldText)
        self.att?.append(normalText)
    }

}
