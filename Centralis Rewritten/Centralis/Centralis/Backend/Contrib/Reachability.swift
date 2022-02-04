//
//  Reachability.swift
//  Centralis
//
//  Created by Amy While on 30/01/2022.
//

import Foundation
import Network

final public class Reachability {

    public static let shared: Reachability = Reachability()
    public weak var delegate: ReachabilityChange?
    
    private let serialQueue = DispatchQueue(label: "com.amywhile.Valery/Reachability", qos: .background)
    
    private lazy var pathMonitor: NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.start(queue: serialQueue)
        monitor.pathUpdateHandler = { path in
            let connected = self.connected
            self.path = path
            if connected != self.connected {
                self.delegate?.statusDidChange(connected: self.connected)
            }
        }
        return monitor
    }()
    private lazy var path = pathMonitor.currentPath
    
    private var firstLock = true
    public var connected: Bool {
        if firstLock {
            firstLock = false
            return true
        }
        return path.status == .satisfied
    }
    
    init() {
        _ = path
    }
    
}

public protocol ReachabilityChange: AnyObject {
    func statusDidChange(connected: Bool)
}
