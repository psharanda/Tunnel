//
//  TunnelTests.swift
//  Tunnel
//
//  Created by Pavel Sharanda on 10/24/18.
//  Copyright © 2018 Tunnel. All rights reserved.
//

import Foundation
import XCTest
import Tunnel

class TunnelTests: XCTestCase {
    func testExample() {
        
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

//func test() {
//    let transition = AnimatedTransition(duration: 0.3, tunnels: [
//        Tunnels.Alpha(key: .from, to: 1),
//        Tunnels.Alpha(key: .to, to: 0),
//        Tunnels.Transfer { (from: A, to: B) in
//            return (from.labelTransferSource, to.labelTransferDestination)
//        }
//    ])
//}
//
//class A: UIViewController {
//    
//    private let label = UILabel()
//    
//    var labelTransferSource: TransferSource<UILabel> {
//        return TransferSource(install: { context in
//            self.label.alpha = 0
//
//            let tmpLabel = UILabel()
//            tmpLabel.text = self.label.text
//
//            context.containerView.addSubview(tmpLabel)
//
//            tmpLabel.mimicGeometry(of: self.label)
//
//            return tmpLabel
//        }, animate: { _ in
//            
//        }, uninstall: { tmpLabel in
//            self.label.alpha = 1
//            tmpLabel.removeFromSuperview()
//        })
//    }
//}
//
//
//
//class B: UIViewController {
//    
//    private let label = UILabel()
//
//    var labelTransferDestination: TransferDestination<UILabel> {
//        return TransferDestination(install: { _ in
//            self.label.alpha = 0
//        }, animate: { view in
//            view.mimicGeometry(of: self.label)
//        }, uninstall: { _ in
//            self.label.alpha = 1
//        })
//    }
//}
