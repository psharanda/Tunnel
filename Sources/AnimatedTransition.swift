//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

public final class AnimatedTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public enum ViewOrder {
        case toFirst
        case fromFirst
    }
    
    public enum AnimationType {
        
        public enum Curve {
            case linear
            case easeIn
            case easeOut
            case easeInOut
            
            var asOptions: UIView.AnimationOptions {
                switch self {
                case .linear:
                    return .curveLinear
                case .easeIn:
                    return .curveEaseIn
                case .easeOut:
                    return .curveEaseOut
                case .easeInOut:
                    return .curveEaseInOut
                }
            }
        }
        
        public enum CalculationMode {
            case linear
            case discrete
            case paced
            case cubic
            case cubicPaced
            
            var asOptions: UIView.KeyframeAnimationOptions {
                switch self {
                case .linear:
                    return .calculationModeLinear
                case .discrete:
                    return .calculationModeDiscrete
                case .paced:
                    return .calculationModePaced
                case .cubic:
                    return .calculationModeCubic
                case .cubicPaced:
                    return .calculationModeCubicPaced
                }
            }
        }
        
        case normal(curve: Curve)
        case spring(dampingRatio: CGFloat, initialVelocity: CGFloat, curve: Curve)
        case keyframes(calculationMode: CalculationMode)
    }
    
    public let duration: TimeInterval
    public let delay: TimeInterval
    public let viewOrder: ViewOrder
    public let animationType: AnimationType
    public let tunnels: [TunnelProtocol]
    
    public init(duration: TimeInterval, delay: TimeInterval = 0, viewOrder: ViewOrder = .fromFirst, animationType: AnimationType = .normal(curve: .easeInOut), tunnels: [TunnelProtocol]) {
        self.duration = duration
        self.delay = delay
        self.viewOrder = viewOrder
        self.animationType = animationType
        self.tunnels = tunnels
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let containerView = transitionContext.containerView
        
        switch viewOrder {
        case .fromFirst:
            if let fromView = fromView {
                containerView.addSubview(fromView)
            }
            if let toView = toView {
                containerView.addSubview(toView)
            }
        case .toFirst:
            if let toView = toView {
                containerView.addSubview(toView)
            }
            if let fromView = fromView {
                containerView.addSubview(fromView)
            }
        }
        
        if transitionContext.isAnimated {
            
            tunnels.forEach { $0.install(using: transitionContext) }
            
            let animations = {
                self.tunnels.forEach { $0.animate(using: transitionContext) }
            }
            
            let completion = { (finished: Bool) in
                self.tunnels.forEach { $0.uninstall(using: transitionContext) }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            
            switch animationType {
            case .normal(let curve):
                
                UIView.animate(withDuration: duration, delay: delay, options: curve.asOptions, animations: animations, completion: completion)
            case .spring(let dampingRatio, let initialVelocity, let curve):
                UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialVelocity, options: curve.asOptions, animations: animations, completion: completion)
            case .keyframes(let calculationMode):
                UIView.animateKeyframes(withDuration: duration, delay: delay, options: calculationMode.asOptions, animations: animations, completion: completion)
            }
        } else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
