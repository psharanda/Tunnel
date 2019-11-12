//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

extension Tunnels {
    public class ViewProperty: TunnelProtocol {
        
        private let installClosure: (UIViewControllerContextTransitioning) -> Void
        private let animateClosure: (UIViewControllerContextTransitioning) -> Void
        private let uninstallClosure: (UIViewControllerContextTransitioning) -> Void
        
        public init<T>(key: UITransitionContextViewKey, from: T, to: T, getter: @escaping (UIView) -> T, setter: @escaping (UIView, T) -> Void) {
            
            var previous: T?
            
            installClosure = { (transitionContext: UIViewControllerContextTransitioning) in
                if let view = transitionContext.view(forKey: key) {
                    previous = getter(view)
                    setter(view, from)
                }
                
            }
            
            animateClosure = { (transitionContext: UIViewControllerContextTransitioning) in
                if let view = transitionContext.view(forKey: key) {
                    setter(view, to)
                }
            }
            
            uninstallClosure = { (transitionContext: UIViewControllerContextTransitioning) in
                if let previous = previous {
                    if let view = transitionContext.view(forKey: key) {
                        setter(view, previous)
                    }
                }
            }
        }
        
        public func install(using transitionContext: UIViewControllerContextTransitioning) {
            installClosure(transitionContext)
        }
        
        public func animate(using transitionContext: UIViewControllerContextTransitioning) {
            animateClosure(transitionContext)
        }
        
        public func uninstall(using transitionContext: UIViewControllerContextTransitioning) {
            uninstallClosure(transitionContext)
        }
    }
    
    public final class Alpha: ViewProperty {
        
        public init(key: UITransitionContextViewKey, from: CGFloat, to: CGFloat) {
            super.init(key: key, from: from, to: to, getter: { $0.alpha }, setter: { $0.alpha = $1 })
        }
    }
    
    public final class Transform: ViewProperty {
        
        public init(key: UITransitionContextViewKey, from: CGAffineTransform, to: CGAffineTransform) {
            super.init(key: key, from: from, to: to, getter: { $0.transform }, setter: { $0.transform = $1 })
        }
    }
    
    public final class Bounds: ViewProperty {
        
        public init(key: UITransitionContextViewKey, from: CGRect, to: CGRect) {
            super.init(key: key, from: from, to: to, getter: { $0.bounds }, setter: { $0.bounds = $1 })
        }
    }
    
    public final class Center: ViewProperty {
        
        public init(key: UITransitionContextViewKey, from: CGPoint, to: CGPoint) {
            super.init(key: key, from: from, to: to, getter: { $0.center }, setter: { $0.center = $1 })
        }
    }
}
