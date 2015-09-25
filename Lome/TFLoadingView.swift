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
    
    func showLoadingView(loadingInfo: String? = nil) {
        let loadingView = NSBundle.mainBundle().loadNibNamed("TFLoadingView", owner: self, options: nil)[0] as! TFLoadingView
        loadingView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
        loadingView.loadingLabel.text = loadingInfo
        loadingView.alpha = 0
        
        view.addSubview(loadingView)
        
        UIView.animateWithDuration(0.3) {
            loadingView.alpha = 1
        }
    }
    
    func hideLoadingView() {
        for aView in view.subviews {
            if aView.isKindOfClass(TFLoadingView) {
                UIView.animateWithDuration(0.5, animations: {
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