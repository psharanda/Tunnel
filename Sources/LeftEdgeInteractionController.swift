//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

public final class LeftEdgeInteractionController {
    
    public var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    
    public var interactionController: UIPercentDrivenInteractiveTransition? {
        return _interactionController
    }
    
    private var _interactionController: UIPercentDrivenInteractiveTransition?
    
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
            _interactionController = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewController(animated: true)
        case .changed:
            _interactionController?.update(percent)
            
        case .ended:
            let velocity = gesture.velocity(in: gesture.view)
    
            if percent > 0.5 || velocity.x > 0 {
                _interactionController?.finish()
            }
            else {
                _interactionController?.cancel()
            }
            _interactionController = nil
        case .cancelled:
            _interactionController?.cancel()
            _interactionController = nil
        default:
            break
        }
    }
    
}
