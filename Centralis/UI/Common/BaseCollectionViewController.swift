//
//  BaseCollectionViewController.swift
//  Centralis
//
//  Created by Amy While on 27/08/2022.
//

import UIKit

class BaseCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .backgroundColor
        NotificationCenter.default.addObserver(self.collectionView!,
                                               selector: #selector(collectionView.reloadData),
                                               name: ThemeManager.ThemeUpdate,
                                               object: nil)
    }

}
