//
//  ResizedTableView.swift
//  Centralis
//
//  Created by AW on 28/11/2020.
//

import UIKit

final class ResizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
