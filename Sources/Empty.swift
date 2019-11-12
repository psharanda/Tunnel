//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

extension Tunnels {
    
    public final class Empty: TunnelProtocol {
        
        public init() { }
        public func install(using transitionContext: UIViewControllerContextTransitioning) { }
        public func animate(using transitionContext: UIViewControllerContextTransitioning) { }
        public func uninstall(using transitionContext: UIViewControllerContextTransitioning) { }
    }
}
