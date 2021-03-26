//
//  CGFloat+Cache.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 12/04/19.
//

import Foundation
import UIKit

extension CGFloat {
    func cached(with key: String) -> CGFloat {
        HeightCache.shared.setHeight(self, for: key)
        return self
    }
}
