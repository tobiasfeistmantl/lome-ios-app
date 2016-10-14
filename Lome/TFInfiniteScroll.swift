//
//  TFInfiniteScroll.swift
//  Lome
//
//  Created by Tobias Feistmantl on 01/10/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation

protocol TFInfiniteScroll {
    var nextPage: Int { get set }
    var hasReachedTheEnd: Bool { get set }
    var populatingAtTheMoment: Bool { get set }
    
    func populate(_ reload: Bool)
}
