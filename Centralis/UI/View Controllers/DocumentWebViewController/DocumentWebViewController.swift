//
//  DocumentWebViewController.swift
//  Centralis
//
//  Created by AW on 12/12/2020.
//

import UIKit
import WebKit
//import libCentralis

class DocumentWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    private func setup() {
        if self.document == nil { return }
        if let decodeData = Data(base64Encoded: self.document!.data!, options: .ignoreUnknownCharacters) {
            self.webView.load(decodeData, mimeType: self.document!.mime_type!, characterEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))
        }
    }
}
