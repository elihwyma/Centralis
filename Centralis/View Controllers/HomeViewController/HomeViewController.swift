//
//  HomeViewController.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inboxButton: UIButton!
    
    let status = EduLink_Status()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "\(EduLinkAPI.shared.authorisedUser.forename!) \(EduLinkAPI.shared.authorisedUser.surname!)"
        self.status.status()
    }
    
    private func setup() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = .none
        self.collectionView.register(UINib(nibName: "HomeMenuCell", bundle: nil), forCellWithReuseIdentifier: "Centralis.HomeMenuCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateStatus), name: .SuccesfulStatus, object: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    @objc private func updateStatus() {
        DispatchQueue.main.async {
            self.inboxButton.setTitle("\(EduLinkAPI.shared.status.new_messages!)", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Centralis.TextViewController" {
            let indexPaths: NSArray = self.collectionView.indexPathsForSelectedItems! as NSArray
            let indexPath: IndexPath = indexPaths[0] as! IndexPath
            let menu = EduLinkAPI.shared.personalMenus[indexPath.row]
            let controller = segue.destination as! TextViewController
            switch menu.name! {
            case "Achievement": controller.context = .achievement
            case "Catering": controller.context = .catering
            case "Account Info": controller.context = .personal
            default: fatalError("Not implemented yet")
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 3
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch EduLinkAPI.shared.personalMenus[indexPath.row].name {
        case "Achievement": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Catering": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Account Info": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Homework": self.performSegue(withIdentifier: "Centralis.Homework", sender: nil)
        default: print("Not yet implemented")
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EduLinkAPI.shared.personalMenus.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Centralis.HomeMenuCell", for: indexPath) as! HomeMenuCell
        let menu = EduLinkAPI.shared.personalMenus[indexPath.row]
        cell.name.text = menu.name
        
        return cell
    }
}
