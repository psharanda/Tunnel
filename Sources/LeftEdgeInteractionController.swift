//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

public final class LeftEdgeInteractionController {
    
    public var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    public var interactiveTransition: UIViewControllerInteractiveTransitioning? {
        return percentDrivenInteractiveTransition
    }
    
    private var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition?
    
    private weak var navigationController: UINavigationController?
    
    public init() {
        
    }
    
    public func install(into navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan))
        edgePanGestureRecognizer!.edges = .left
        navigationController.view.addGestureRecognizer(edgePanGestureRecognizer!)
    }
    
    public func uninstall() {
        if let edgePanGestureRecognizer = edgePanGestureRecognizer {
            navigationController?.view.removeGestureRecognizer(edgePanGestureRecognizer)
        }
        navigationController = nil
    }
    
    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        
        guard let view = gesture.view else {
            return
        }
        
        let translate = gesture.translation(in: view)
        let percent = translate.x / view.bounds.size.width
        
        switch gesture.state {
        case .began:
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        case .changed:
            percentDrivenInteractiveTransition?.update(percent)
            
        case .ended:
            let velocity = gesture.velocity(in: gesture.view)    
            if percent > 0.5 || velocity.x > 0 {
                percentDrivenInteractiveTransition?.finish()
            } else {
                percentDrivenInteractiveTransition?.cancel()
            }
            percentDrivenInteractiveTransition = nil
        case .cancelled:
            percentDrivenInteractiveTransition?.cancel()
            percentDrivenInteractiveTransition = nil
        default:
            break
        }
    }
    
}
