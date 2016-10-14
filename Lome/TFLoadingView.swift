//
//  TFLoadingView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 25/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring

class TFLoadingView: DesignableView {
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIViewController {
    
    func showLoadingView(_ loadingInfo: String? = nil) {
        let loadingView = Bundle.main.loadNibNamed("TFLoadingView", owner: self, options: nil)?[0] as! TFLoadingView
        loadingView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        loadingView.loadingLabel.text = loadingInfo
        loadingView.alpha = 0
        
        view.addSubview(loadingView)
        
        UIView.animate(withDuration: 0.3) {
            loadingView.alpha = 1
        }
    }
    
    func hideLoadingView() {
        for aView in view.subviews {
            if aView.isKind(of: TFLoadingView.self) {
                UIView.animate(withDuration: 0.5, animations: {
                    aView.alpha = 0
                }, completion: { finished in
                    if finished {
                        aView.removeFromSuperview()
                    }
                })
            }
        }
    }
    
}
