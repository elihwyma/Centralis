//
//  TeacherPictureDumperController.swift
//  Centralis
//
//  Created by Amy While on 27/08/2022.
//

import UIKit
import Evander

class TeacherPictureDumperController: BaseCollectionViewController {
    
    private var loadedPictures = [UIImage]()
    private let sectionInsets = UIEdgeInsets(
      top: 50.0,
      left: 20.0,
      bottom: 50.0,
      right: 20.0
    )
    private let itemsPerRow: CGFloat = 3
    private var showIndicator = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Teacher Photos"

        collectionView.register(CollectionViewImageCell.self, forCellWithReuseIdentifier: "CollectionViewImageCell")
        collectionView.register(IndicatorCell.self, forCellWithReuseIdentifier: "IndicatorCell")
        
        let alert = UIAlertController(title: "Warning",
                                      message: "This will load all the staff photos for your organisation. This may take a few minutes and use a large amount of data depending on the size of the organisation. Please be patient",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.startImageDump()
        })
        self.present(alert, animated: true)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 1
        collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc private func handleLongPress(_ gestureRecogniser: UILongPressGestureRecognizer) {
        if gestureRecogniser.state != .ended {
            return
        }

        let p = gestureRecogniser.location(in: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: p) {
            guard indexPath.section == 0 else { return }
            let image = loadedPictures[indexPath.row]
            let alert = UIAlertController(title: "Save Image?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                weak var weakSelf = self
                UIImageWriteToSavedPhotosAlbum(image, weakSelf, #selector(self.saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
            })
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.collectionView.cellForItem(at: indexPath)
            }
            self.present(alert, animated: true)
       }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        guard let error = error else { return }
        let alert = UIAlertController(title: "Error Saving Photo", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
    deinit {
        Photos.shared.cancelDump = true
    }
    
    private func changeIndicator(_ show: Int) {
        Thread.mainBlock { [weak self] in
            guard let self = self else { return }
            if show == self.showIndicator { return }
            if show == 0 {
                self.showIndicator = 0
                self.collectionView.deleteItems(at: [IndexPath(row: 0, section: 1)])
            } else {
                self.showIndicator = 1
                self.collectionView.insertItems(at: [IndexPath(row: 0, section: 1)])
            }
        }
    }
    
    private func startImageDump() {
        changeIndicator(1)
        let shared = Photos.shared
        shared.dumpAllEmployeePhotos { [weak self] image in
            Thread.mainBlock {
                guard let self = self else { return }
                self.loadedPictures.append(image)
                self.collectionView.insertItems(at: [IndexPath(row: self.loadedPictures.count - 1, section: 0)])
            }
        } completion: { [weak self] in
            self?.changeIndicator(0)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? loadedPictures.count : showIndicator
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IndicatorCell", for: indexPath) as! IndicatorCell
            cell.indicator.startAnimating()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewImageCell", for: indexPath) as! CollectionViewImageCell
        cell.imageView.image = loadedPictures[indexPath.row]
        return cell
    }
    
}

extension TeacherPictureDumperController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {
      if indexPath.section == 1 {
          return CGSize(width: view.frame.width - 100, height: 50)
      }
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
    
      return CGSize(width: widthPerItem, height: widthPerItem)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int ) -> UIEdgeInsets {
      sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      sectionInsets.left
  }
    
}
