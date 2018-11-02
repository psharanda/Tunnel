//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import Foundation
import UIKit

public protocol AnimationControllerProtocol: UIViewControllerAnimatedTransitioning {
    func canHandleTransition(from fromVC: UIViewController, to toVC: UIViewController) -> Bool
}

public class AnimationController<From: UIViewController, To: UIViewController>: NSObject, AnimationControllerProtocol {
    
    public enum AddViewsMode {
        case toFirst
        case fromFirst
    }
    
    public let duration: TimeInterval
    public let addViewsMode: AddViewsMode
    public init(duration: TimeInterval, addViewsMode: AddViewsMode) {
        self.duration = duration
        self.addViewsMode = addViewsMode
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? From else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? To else { return }
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        let containerView = transitionContext.containerView
        
        let context = TransitionContext(duration: duration,
                                        fromViewController: fromViewController,
                                        fromView: fromView,
                                        toViewController: toViewController,
                                        toView: toView,
                                        containerView: containerView,
                                        transitionContext: transitionContext)
        
        context.addViewsToContainer(addViewsMode)
        doAnimateTransition(using: context)
    }
    
    public struct TransitionContext {
        public let duration: TimeInterval
        public let fromViewController: From
        public let fromView: UIView?
        public let toViewController: To
        public let toView: UIView?
        public let containerView: UIView
        public let transitionContext: UIViewControllerContextTransitioning
        
        public func complete() {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        public func addViewsToContainer(_ mode: AddViewsMode) {
            switch mode {
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
        }
        
        public enum AnimationType {
            case normal
            case spring(dampingRatio: CGFloat, initialVelocity: CGFloat)
        }
        
        public func animate(tunnels: [Tunnel], animationType: AnimationType = .normal, delay: TimeInterval = 0, options: UIView.AnimationOptions = []) {
            
            toView?.setNeedsLayout()
            toView?.layoutIfNeeded()
            
            tunnels.forEach {
                $0.install(containerView: containerView)
            }
            
            let animations = {
                tunnels.forEach {
                    $0.animate(containerView: self.containerView)
                }
            }
            
            let completion = { (finished: Bool) in
                
                tunnels.forEach {
                    $0.uninstall(containerView: self.containerView)
                }
                
                self.complete()
            }
            
            switch animationType {
            case .normal:
                UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
            case .spring(let dampingRatio, let initialVelocity):
                UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialVelocity, options: options, animations: animations, completion: completion)
            }
        }
    }
    
    public func doAnimateTransition(using transitionContext: TransitionContext) {
        
    }
    
    public func canHandleTransition(from fromVC: UIViewController, to toVC: UIViewController) -> Bool {
        return fromVC is From && toVC is To
    }
}

public class NavigationAnimationControllerDispatcher: NSObject, UINavigationControllerDelegate {
    
    private var popAnimationControllers = [()->AnimationControllerProtocol]()
    private var pushAnimationControllers = [()->AnimationControllerProtocol]()
    
    public func registerAnimationController(for operation: UINavigationController.Operation, initializer: @escaping ()->AnimationControllerProtocol) {
        switch operation {
        case .pop:
            popAnimationControllers.append(initializer)
        case .push:
            pushAnimationControllers.append(initializer)
        case .none:
            break
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        var aci: [()->AnimationControllerProtocol]? {
            switch operation {
            case .pop:
                return popAnimationControllers
            case .push:
                return pushAnimationControllers
            case .none:
                return nil
            }
        }
        
        guard let animationControllersInitializers = aci else {
            return nil
        }
        
        for initializer in animationControllersInitializers {
            let animationController = initializer()
            if animationController.canHandleTransition(from: fromVC, to: toVC) {
                return animationController
            }
        }
        return nil
    }
}


public struct Tunnel {
    
    public let installClosure: (UIView)->Void
    public let animateClosure: (UIView)->Void
    public let uninstallClosure: (UIView)->Void
    public init(install: @escaping (UIView)->Void = {_ in }, animate: @escaping (UIView)->Void = {_ in }, uninstall: @escaping (UIView)->Void = {_ in }) {
        installClosure = install
        animateClosure = animate
        uninstallClosure = uninstall
    }
    
    public func install(containerView: UIView) {
        installClosure(containerView)
    }
    
    public func animate(containerView: UIView) {
        animateClosure(containerView)
    }
    
    public func uninstall(containerView: UIView) {
        uninstallClosure(containerView)
    }
}

extension Tunnel {
    public init(tunnels: [Tunnel]) {
        self.init(install: { container in
            tunnels.forEach { $0.install(containerView: container)  }
        }, animate: { container in
            tunnels.forEach { $0.animate(containerView: container)  }
        }, uninstall: { container in
            tunnels.forEach { $0.uninstall(containerView: container)  }
        })
    }
}
    
extension Tunnel {
    public init<T>(view: UIView?, fromValue: T?, toValue: T, finalValue: T, setter: @escaping (UIView, T)->Void) {
        
        self.init(install: { _ in
            if let view = view, let fromValue = fromValue {
                setter(view, fromValue)
            }
        }, animate: { _ in
            if let view = view {
                setter(view, toValue)
            }
        }, uninstall: { _ in
            if let view = view {
                setter(view, finalValue)
            }
        })
    }

    public init(view: UIView?, fromAlpha: CGFloat) {
        self.init(view: view, fromValue: fromAlpha, toValue: 1, finalValue: 1, setter: { $0.alpha = $1 })
    }
    
    public init(view: UIView?, toAlpha: CGFloat) {
        self.init(view: view, fromValue: nil, toValue: toAlpha, finalValue: 1, setter: { $0.alpha = $1 })
    }
    
    public init(view: UIView?, fromTransform: CGAffineTransform) {
        self.init(view: view, fromValue: fromTransform, toValue: .identity, finalValue: .identity, setter: { $0.transform = $1 })
    }
    
    public init(view: UIView?, toTransform: CGAffineTransform) {
        self.init(view: view, fromValue: nil, toValue: toTransform, finalValue: .identity, setter: { $0.transform = $1 })
    }
    
    public init(view: UIView?, toTransform: CGAffineTransform, toAlpha: CGFloat) {
        self.init(tunnels: [Tunnel(view: view, toTransform: toTransform), Tunnel(view: view, toAlpha: toAlpha)])
    }
    
    public init(view: UIView?, fromTransform: CGAffineTransform, fromAlpha: CGFloat) {
        self.init(tunnels: [Tunnel(view: view, fromTransform: fromTransform), Tunnel(view: view, fromAlpha: fromAlpha)])
    }
}

public struct TunnelSnapshotProps {
    public var bounds: CGRect
    public var center: CGPoint
    public var transform: CGAffineTransform
    public var alpha: CGFloat
    public var backgroundColor: UIColor?
}

extension Tunnel {

    public init<View: UIView, FromView: UIView, ToView: UIView>(view: View,
                                                         fromView: FromView,
                                                         toView: ToView,
                                                         mapFromProps: @escaping (FromView, TunnelSnapshotProps) -> TunnelSnapshotProps = { _, props in props },
                                                         mapToProps: @escaping (ToView, TunnelSnapshotProps) -> TunnelSnapshotProps = { _, props in props }) {
        self.init(install: { containerView in
            containerView.addSubview(view)
            fromView.isHidden = true
            toView.isHidden = true
            view.install(props: mapFromProps(fromView, fromView.extractProps(whenIn: containerView)))
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }, animate: { containerView in
            view.install(props: mapToProps(toView, toView.extractProps(whenIn: containerView)))
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }, uninstall: { containerView in
            fromView.isHidden = false
            toView.isHidden = false
            view.removeFromSuperview()
        })
    }
    
    public static var empty: Tunnel {
        return Tunnel()
    }
}



extension UIView {
    fileprivate func extractProps(whenIn container: UIView) -> TunnelSnapshotProps {
        return TunnelSnapshotProps(
            bounds: bounds,
            center: container.convert(center, from: superview),
            transform: transform,
            alpha: alpha,
            backgroundColor: backgroundColor)
    }
    
    fileprivate func install(props: TunnelSnapshotProps) {
        bounds = props.bounds
        center = props.center
        transform = props.transform
        alpha = props.alpha
        backgroundColor = props.backgroundColor
    }
}

extension UIView {
    public func copyProperties(from other: UIView) {
        tintColor = other.tintColor
        contentMode = other.contentMode
        layer.borderColor = other.layer.borderColor
        layer.borderWidth = other.layer.borderWidth
        layer.cornerRadius = other.layer.cornerRadius
        layer.shadowOffset = other.layer.shadowOffset
        layer.shadowColor = other.layer.shadowColor
        layer.shadowPath = other.layer.shadowPath
        layer.shadowOpacity = other.layer.shadowOpacity
        layer.shadowRadius = other.layer.shadowRadius
    }
}

extension UILabel {
    public func copyProperties(from other: UILabel) {
        super.copyProperties(from: other)
        textColor = other.textColor
        textAlignment = other.textAlignment
        font = other.font
        numberOfLines = other.numberOfLines
        shadowColor = other.shadowColor
        shadowOffset = other.shadowOffset
        
        if let a = other.attributedText {
            attributedText = a
        } else {
            text = other.text
        }
    }
}


extension UIImageView {
    public func copyProperties(from other: UIImageView) {
        super.copyProperties(from: other)
        image = other.image
        highlightedImage = other.highlightedImage
        isHighlighted = other.isHighlighted
    }
}

extension UIControl {
    public func copyProperties(from other: UIControl) {
        super.copyProperties(from: other)
        contentVerticalAlignment = other.contentVerticalAlignment
        contentHorizontalAlignment = other.contentHorizontalAlignment
        isSelected = other.isSelected
        isEnabled = other.isEnabled
    }
}

extension UIButton {
    public func copyProperties(from other: UIButton) {
        super.copyProperties(from: other)
        
        setImage(other.image(for: .normal), for: .normal)
        setTitle(other.title(for: .normal), for: .normal)
        setTitleColor(other.titleColor(for: .normal), for: .normal)
        setTitleShadowColor(other.titleShadowColor(for: .normal), for: .normal)
        setAttributedTitle(other.attributedTitle(for: .normal), for: .normal)
        setBackgroundImage(other.backgroundImage(for: .normal), for: .normal)
        imageEdgeInsets = other.imageEdgeInsets
        titleEdgeInsets = other.titleEdgeInsets
        titleLabel?.font = other.titleLabel?.font
        imageView?.contentMode = other.imageView?.contentMode ?? .scaleToFill
    }
}

extension UITextField {
    public func copyProperties(from other: UITextField) {
        super.copyProperties(from: other)
        
        textColor = other.textColor
        textAlignment = other.textAlignment
        font = other.font
        if let a = other.attributedText {
            attributedText = a
        } else {
            text = other.text
        }
        if let p = other.attributedPlaceholder {
            attributedPlaceholder = p
        } else {
            placeholder = other.placeholder
        }
    }
}

