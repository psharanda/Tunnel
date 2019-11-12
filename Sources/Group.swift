//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

extension Tunnels {
    public final class Group: TunnelProtocol {

        public let tunnels: [TunnelProtocol]
        
        public init(tunnels: [TunnelProtocol]) {
            self.tunnels = tunnels
        }
        
        public func install(using transitionContext: UIViewControllerContextTransitioning) {
            tunnels.forEach { $0.install(using: transitionContext) }
        }
        
        public func animate(using transitionContext: UIViewControllerContextTransitioning) {
            tunnels.forEach { $0.animate(using: transitionContext) }
        }
        
        public func uninstall(using transitionContext: UIViewControllerContextTransitioning) {
            tunnels.forEach { $0.uninstall(using: transitionContext) }
        }
    }
}
