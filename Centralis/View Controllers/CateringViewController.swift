//
//  CateringViewController.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import UIKit

class CateringViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let catering = EduLink_Catering()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title()
    }
    
    private func title() {
        if let balance = EduLinkAPI.shared.catering.balance {
            self.title = "Balance: \(self.formatPrice(balance))"
        }
    }
    
    private func setup() {
        self.tableView.backgroundColor = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "CateringCell", bundle: nil), forCellReuseIdentifier: "Centralis.CateringCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.catering.catering()
        NotificationCenter.default.addObserver(self, selector: #selector(cateringResponse), name: .SuccesfulCatering, object: nil)
    }
    
    @objc private func cateringResponse() {
        DispatchQueue.main.async {
            self.title()
            self.tableView.reloadData()
        }
    }
    
    private func formatPrice(_ number: Double) -> String {
        let numstring = String(format: "%03.2f", number)
        return "£\(numstring)"
    }
}

extension CateringViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CateringViewController : UITableViewDataSource {
    
    //This is just meant to be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EduLinkAPI.shared.catering.transactions.count
    }

    //This is what handles all the images and text etc, using the class mainScreenTableCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.CateringCell", for: indexPath) as! CateringCell
        let transaction = EduLinkAPI.shared.catering.transactions[indexPath.row]
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        let attributedDateTitle = NSMutableAttributedString(string: "Date & Time: ", attributes: boldAttributes)
        let attributedDate = NSAttributedString(string: transaction.date, attributes: fontAttributes)
        attributedDateTitle.append(attributedDate)
        
        let transactionsAtt = NSMutableAttributedString(string: "\nItems & Amount: \n", attributes: boldAttributes)
        for (index, item) in transaction.items.enumerated() {
            let ext: String = ((index == transaction.items.count - 1) ? "" : "\n")
            transactionsAtt.append(NSAttributedString(string: "\(item.item!): \(self.formatPrice(item.price))\(ext)", attributes: fontAttributes))
        }
        attributedDateTitle.append(transactionsAtt)
        cell.transactionsView.attributedText = attributedDateTitle
        cell.transactionsView.textColor = .label
        
        return cell
    }
}

