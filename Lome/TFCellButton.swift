//
//  TFCellButton.swift
//  Lome
//
//  Created by Tobias Feistmantl on 20/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

class TFCellButton: UIButton {
    var indexPath: IndexPath?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
