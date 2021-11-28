//
//  EdulinkManager.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import Evander

final public class EdulinkManager {
    
    static var shared = EdulinkManager()
    public var authenticatedUser: AuthenticatedUser?
    public var pingQueue = DispatchQueue(label: "Centralis.PingQueue", qos: .background)
    public var session: Session? {
        didSet {
            pingQueue.async { [weak self] in
                guard let `self` = self else { return }
                self.pingTimer?.invalidate()
                guard self.session != nil else { return }
                self.pingTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { timer in
                    Ping.ping { error, _ in
                        #warning("This Error Needs to be handled")
                    }
                }
                RunLoop.current.run()
            }
        }
    }
    public var pingTimer: Timer?
    
    public func signout() {
        try? PersistenceDatabase.shared.resetDatabase()
        NotificationManager.shared.removeAllNotifications()
        LoginManager.save(login: nil)
        Self.shared = EdulinkManager()
    }
}
