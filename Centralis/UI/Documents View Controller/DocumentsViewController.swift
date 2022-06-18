//
//  DocumentsViewController.swift
//  Centralis
//
//  Created by Amy While on 06/02/2022.
//

import UIKit
import QuickLook
import Evander

class DocumentsViewController: CentralisDataViewController {
    
    var documents = [Document]()
    private var targetURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"
        tableView.register(DocumentCell.self, forCellReuseIdentifier: "Centralis.DocumentCell")
    }
    
    override public func index(_ reload: Bool = true) {
        if reload {
            tableView.beginUpdates()
        }
        var documents = Array(PersistenceDatabase.shared.documents.values)
        documents.sort { $0.last_updated ?? Date() > $1.last_updated ?? Date() }
        if documents != self.documents {
            self.documents = documents
            if reload {
                tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        if reload {
            tableView.endUpdates()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        documents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.DocumentCell", for: indexPath) as! DocumentCell
        cell.set(document: documents[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        downloadDocument(indexPath)
    }
    
    private func display(with url: URL) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.display(with: url)
            }
            return
        }
        self.dismiss(animated: true)
        targetURL = url
        let quickLookViewController = QLPreviewController()
        quickLookViewController.dataSource = self
        quickLookViewController.currentPreviewItemIndex = 0
        present(quickLookViewController, animated: true)
    }
    
    @objc private func downloadDocument(_ indexPath: IndexPath) {
        let document = documents[indexPath.row]
        if Document.documentsFolder.dirExists {
            if document.fileDestination.exists {
                self.display(with: document.fileDestination)
                return
            }
        } else {
            try? FileManager.default.createDirectory(at: Document.documentsFolder, withIntermediateDirectories: true)
        }
        
        let alert = UIAlertController(title: "Downloading \(document.filename)", message: "Resolving", preferredStyle: .alert)
        var cancel = false
        var downloader: EvanderDownloader?
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            cancel = true
            downloader?.cancel()
        })
        present(alert, animated: true) { [weak self] in
            guard let self = self else { return }
            let foundLabel = alert.label(with: "Resolving")
            document.getDocument { error, url in
                guard let url = url,
                      !cancel else {
                    Thread.mainBlock {
                        foundLabel?.text = error ?? "Unknown Error"
                    }
                    return
                }
                if url.isFileURL {
                    return self.display(with: url)
                } else {
                    downloader = EvanderDownloader(url: url)
                    downloader?.make()
                    downloader?.progressCallback = { progress in
                        guard !cancel else { return }
                        let percent = progress.fractionCompleted * 100.0
                        Thread.mainBlock {
                            foundLabel?.text = "\(Int(percent))% downloaded"
                        }
                    }
                    downloader?.errorCallback = { _, error, _ in
                        guard !cancel else { return }
                        Thread.mainBlock {
                            foundLabel?.text = error?.localizedDescription
                        }
                    }
                    downloader?.didFinishCallback = { _, url in
                        guard !cancel else { return }
                        try? FileManager.default.moveItem(at: url, to: document.fileDestination)
                        self.display(with: document.fileDestination)
                    }
                    downloader?.resume()
                }
            }
        }
    }
    
}

extension DocumentsViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        targetURL! as NSURL
    }
}
