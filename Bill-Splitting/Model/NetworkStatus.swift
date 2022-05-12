//
//  NetworkStatus.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/12.
//

import Network

class NetworkStatus {
    static let shared = NetworkStatus()
    
    private init() {
        
    }
    
    deinit {
        stopMonitoring()
    }

    
    var monitor: NWPathMonitor?
    
    var isMonitoring: Bool = false
    
    var isConnected: Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
    
    var didStartMonitoringHandler: (() -> Void)?

    var didStopMonitoringHandler: (() -> Void)?

    var netStatusChangeHandler: (() -> Void)?
    
    func startMonitoring() {
        if !isMonitoring {
            monitor = NWPathMonitor()
            
            let queue = DispatchQueue(label: "NetworkStatusMonitor")
            monitor?.start(queue: queue)
            
            monitor?.pathUpdateHandler = { _ in
                   self.netStatusChangeHandler?()
               }
            
            isMonitoring = true
            didStartMonitoringHandler?()
        }
    }
    
    func stopMonitoring() {
        guard isMonitoring,
                let monitor = monitor
        else { return }
        
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
        didStopMonitoringHandler?()
    }
}
