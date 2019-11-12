//
//  Tunnel - UIViewController transitions microframework
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import UIKit

extension UIView {
    private struct Geometry {
        var bounds: CGRect
        var center: CGPoint
        var transform: CGAffineTransform
    }
    
    private func geometry(in view: UIView) -> Geometry {
        return Geometry(bounds: bounds, center: view.convert(center, from: superview), transform: transform)
    }
    
    private func apply(geometry: Geometry) {
        bounds = geometry.bounds
        center = geometry.center
        transform = geometry.transform
    }
    
    public func mimicGeometry(of view: UIView) {
        if let superview = superview {
            apply(geometry: view.geometry(in: superview))
        }
    }
}
