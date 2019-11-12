//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

public protocol TunnelProtocol {
    func install(using transitionContext: UIViewControllerContextTransitioning)
    func animate(using transitionContext: UIViewControllerContextTransitioning)
    func uninstall(using transitionContext: UIViewControllerContextTransitioning)
}

public enum Tunnels { }






