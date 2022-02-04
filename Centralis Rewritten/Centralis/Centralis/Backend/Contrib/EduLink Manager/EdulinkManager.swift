//
//  EdulinkManager.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import Evander
import UIKit

final public class EdulinkManager {
    
    static var shared = EdulinkManager()
    public var authenticatedUser: AuthenticatedUser?
    public var pingQueue = DispatchQueue(label: "Centralis.PingQueue", qos: .background)
    public var session: Session? {
        didSet {
            Thread.mainBlock { [weak self] in
                guard UIApplication.shared.applicationState == .active else { return }
                self?.pingQueue.async { [weak self] in
                    guard let `self` = self else { return }
                    self.pingTimer?.invalidate()
                    guard self.session != nil else { return }
                    self.pingTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { timer in
                        Ping.ping { error, _ in
                            CentralisTabBarController.shared.set(title: "Error with ping", subtitle: error ?? "Unknown Error", progress: 0)
                        }
                    }
                    RunLoop.current.run()
                }
            }
        }
    }
    public var pingTimer: Timer?
    
    public func signout() {
        try? PersistenceDatabase.shared.resetDatabase()
        NotificationManager.shared.removeAllNotifications()
        LoginManager.save(login: nil)
        Self.shared = EdulinkManager()
        Message.setUnread()
    }
}
