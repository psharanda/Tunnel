//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

extension Tunnels {
    
    public final class Transfer<T>: TunnelProtocol {

        private var source: TransferSource<T>?
        private var destination: TransferDestination<T>?
        private var transferable: T?

        private let setup: (UIViewControllerContextTransitioning) -> (TransferSource<T>?, TransferDestination<T>?)

        public init<From: UIViewController, To: UIViewController>(setup: @escaping (From, To) -> (TransferSource<T>, TransferDestination<T>)) {
            self.setup = { context in
                if let from = context.viewController(forKey: .from) as? From, let to = context.viewController(forKey: .to) as? To {
                    return setup(from, to)
                } else {
                    return (nil, nil)
                }
            }
        }

        public func install(using transitionContext: UIViewControllerContextTransitioning) {
            (source, destination) = setup(transitionContext)

            transferable = source?.install(using: transitionContext)
            if let transferable = transferable {
                destination?.install(transferable: transferable)
            }
        }

        public func animate(using transitionContext: UIViewControllerContextTransitioning) {
            if let transferable = transferable {
                source?.animate(transferable: transferable)
                destination?.animate(transferable: transferable)
            }
        }

        public func uninstall(using transitionContext: UIViewControllerContextTransitioning) {
            if let transferable = transferable {
                source?.uninstall(transferable: transferable)
                destination?.uninstall(transferable: transferable)
            }
            transferable = nil
        }
    }
}

public final class TransferSource<T> {
    
    private let installClosure: (UIViewControllerContextTransitioning) -> T
    private let animateClosure: (T) -> Void
    private let uninstallClosure: (T) -> Void
    
    public init(install: @escaping (UIViewControllerContextTransitioning) -> T,
         animate: @escaping (T) -> Void,
         uninstall: @escaping (T) -> Void) {
        
        self.installClosure = install
        self.animateClosure = animate
        self.uninstallClosure = uninstall
    }
    
    fileprivate func install(using transitionContext: UIViewControllerContextTransitioning) -> T {
        return installClosure(transitionContext)
    }
    
    fileprivate func animate(transferable: T) {
        animateClosure(transferable)
    }
    
    fileprivate func uninstall(transferable: T) {
        uninstallClosure(transferable)
    }
}

public final class TransferDestination<T> {
    
    private let installClosure: (T) -> Void
    private let animateClosure: (T) -> Void
    private let uninstallClosure: (T) -> Void
    
    public init(install: @escaping (T) -> Void,
         animate: @escaping (T) -> Void,
         uninstall: @escaping (T) -> Void) {
        
        self.installClosure = install
        self.animateClosure = animate
        self.uninstallClosure = uninstall
    }
    
    fileprivate func install(transferable: T) {
        installClosure(transferable)
    }
    
    fileprivate func animate(transferable: T) {
        animateClosure(transferable)
    }
    
    fileprivate func uninstall(transferable: T) {
        uninstallClosure(transferable)
    }
}

