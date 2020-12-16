//
//  HomeViewController.swift
//  Centralis
//
//  Created by Amy While on 01/12/2020.
//

import UIKit

class HomeViewController: UIViewController {
    
    let completedMenus: [String] = [
        "Achievement",
        "Catering",
        "Account Info",
        "Homework",
        "Timetable",
        "Links",
        "Documents",
        "Behaviour"
    ]
    
    private var shownMenus = [PersonalMenu]()

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
        
        #if DEBUG
        self.shownMenus = EduLinkAPI.shared.authorisedUser.personalMenus
        #else
        for m in EduLinkAPI.shared.authorisedUser.personalMenus {
            if completedMenus.contains(m.name) {
                self.shownMenus.append(m)
            }
        }
        #endif
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
        let indexPaths: NSArray = self.collectionView.indexPathsForSelectedItems! as NSArray
        if indexPaths.count == 0 { return }
        let indexPath: IndexPath = indexPaths[0] as! IndexPath
        let menu = shownMenus[indexPath.row]
        if segue.identifier == "Centralis.TextViewController" {
            let controller = segue.destination as! TextViewController
            switch menu.name! {
            case "Achievement": controller.context = .achievement
            case "Catering": controller.context = .catering
            case "Account Info": controller.context = .personal
            case "Links": controller.context = .links
            case "Documents": controller.context = .documents
            default: fatalError("Not implemented yet")
            }
        } else if segue.identifier == "Centralis.ShowCarousel" {
            let controller = segue.destination as! CarouselContainerController
            switch menu.name! {
            case "Homework": controller.context = .homework
            case "Timetable": controller.context = .timetable
            case "Behaviour": controller.context = .behaviour
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
        switch shownMenus[indexPath.row].name {
        case "Achievement": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Catering": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Account Info": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Homework": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Behaviour": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Timetable": self.performSegue(withIdentifier: "Centralis.ShowCarousel", sender: nil)
        case "Links": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        case "Documents": self.performSegue(withIdentifier: "Centralis.TextViewController", sender: nil)
        default: print("Not yet implemented")
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shownMenus.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Centralis.HomeMenuCell", for: indexPath) as! HomeMenuCell
        let menu = shownMenus[indexPath.row]
        cell.name.text = menu.name
        switch menu.name {
        case "Exams": cell.image.image = UIImage(systemName: "envelope.fill")
        case "Documents": cell.image.image = UIImage(systemName: "doc.fill")
        case "Timetable": cell.image.image = UIImage(systemName: "clock.fill")
        case "Account Info": cell.image.image = UIImage(systemName: "person.fill")
        case "Clubs": cell.image.image = UIImage(systemName: "person.3.fill")
        case "Links": cell.image.image = UIImage(systemName: "link.circle.fill")
        case "Homework": cell.image.image = UIImage(systemName: "briefcase.fill")
        case "Catering": cell.image.image = UIImage(systemName: "sterlingsign.square.fill")
        case "Attendance": cell.image.image = UIImage(systemName: "chart.bar.fill")
        case "Behaviour": cell.image.image = UIImage(systemName: "hand.raised.slash.fill")
        case "Achievement": cell.image.image = UIImage(systemName: "wand.and.stars")
        default: break
        }
        return cell
    }
}
