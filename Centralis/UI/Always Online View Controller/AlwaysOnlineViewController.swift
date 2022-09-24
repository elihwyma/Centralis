//
//  AlwaysOnlineViewController.swift
//  Centralis
//
//  Created by Amy While on 24/09/2022.
//

import UIKit
import OnBoardingKit

class AlwaysOnlineViewController: OBSetupAssistantBulletedListController {
    
    public class func create() -> OBSetupAssistantBulletedListController  {
        return AlwaysOnlineViewController(title: "Centralis Uptime Manager",
                                   detailText: "CUM: The newest innovation in Edulink fuckery technology™️",
                                   icon: UIImage(systemName: "network"),
                                   contentLayout: 2)
    }
    
    override init!(title arg1: Any!, detailText arg2: Any!, icon arg3: Any!, contentLayout arg4: Int64) {
        super.init(title: arg1, detailText: arg2, icon: arg3, contentLayout: arg4)
        
        modalPresentationStyle = .pageSheet
        isModalInPresentation = true
        
        addBulletedListItem(withTitle: "Instant Notifications",
                            description: "CUM will constantly check for new content on a remote server saving you battery and allowing you to get instant notifications on new updates to your account",
                            image: UIImage(systemName: "flame"))
        addBulletedListItem(withTitle: "Sign in With Apple",
                            description: "Using CUM allows you to use Sign in With Apple on your devices for an even faster login experience!",
                            image: UIImage(systemName: "person.fill.checkmark"))
        addBulletedListItem(withTitle: "Edulink Sucks",
                            description: "Due to poor lack of proper authentication systems on Edulink your username and password will be stored on the CUM server. Your data is never sold or looked at. I don't care. Find a company that will buy your homework data.",
                            image: UIImage(systemName: "hand.raised.circle"))
        
        let continueButton = OBBoldTrayButton(type: 1)!
        continueButton.addTarget(self, action: #selector(setupAlwaysOnline), for: .touchUpInside)
        continueButton.setTitle("Setup", for: 0)
        continueButton.setTitleColor(.label, for: .normal)
        continueButton.layer.masksToBounds = true
        continueButton.layer.cornerRadius = 15
        continueButton.backgroundColor = .tintColor
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let closeButton = OBBoldTrayButton(type: 1)!
        closeButton.addTarget(self, action: #selector(pop), for: .touchUpInside)
        closeButton.setTitle("No Thanks", for: 0)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = 15
        closeButton.backgroundColor = .secondaryBackgroundColor
        closeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        buttonTray.addButton(continueButton)
        buttonTray.addButton(closeButton)
    }
    
    @objc private func setupAlwaysOnline() {
        PersistenceDatabase.domainDefaults.setValue(true, forKey: "AlwaysOnline.Onboarding")
        AlwaysOnlineManager.shared.registerForOnline { error in
            print(error)
        }
    }
    
    @objc private func pop() {
        PersistenceDatabase.domainDefaults.setValue(true, forKey: "AlwaysOnline.Onboarding")
        self.dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
