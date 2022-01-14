//
//  NSAttributedString+Extensions.swift
//  Centralis
//
//  Created by Andromeda on 04/12/2021.
//

import UIKit

public extension NSMutableAttributedString {
    
    convenience init(html: String) throws {
        let htmlString = """
        <!DOCTYPE html>
        <html style="\(Self.cssVariables)">
        <base target="_blank">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">
        <style>
        body {
            background: var(--background-color);
            font: -apple-system-body;
            color: var(--label-color);
            -webkit-text-size-adjust: none;
        }
        pre, xmp, plaintext, listing, tt, code, kbd, samp {
            font-family: ui-monospace, Menlo;
        }
        a {
            text-decoration: none;
            color: var(--tint-color);
        }
        p, h1, h2, h3, h4, h5, h6, ul, ol {
            margin: 0 0 16px 0;
        }
        body > *:last-child {
            margin-bottom: 0;
        }
        </style>
        <body>\(html)</body>
        </html>
        """
        
        let data = Data(htmlString.utf8)
        try self.init(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
    
    private static var cssVariables: String {
        // TODO: Come up with values for the placeholders, or remove them. Not all are used by
        // DepictionKit. Some are provided for HTML depictions to take advantage of.
        // TODO: Also try and come up with more that might be useful?
        """
        --tint-color: \(ThemeManager.tintColor.cssString);
        --content-background-color: \("#fff");
        --highlight-color: \("#c00");
        --separator-color: \(UIColor.separator.cssString);
        --label-color: \(UIColor.label.cssString);
        """.replacingOccurrences(of: "\n", with: " ")
    }
    
}

internal extension UIColor {

    var cssString: String {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red *= 255
        green *= 255
        blue *= 255
        return String(format: "rgba(%.0f, %.0f, %.0f, %.2f)", red, green, blue, alpha)
    }
    
}
