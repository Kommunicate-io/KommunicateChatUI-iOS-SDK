//
//  UIImaveView+Extension.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

extension UIImageView {

    func cropRedProfile () {
        self.layer.cornerRadius   = 0.5 * self.bounds.size.width
        self.layer.borderColor    = UIColor.color(Color.Border.main).cgColor
        self.layer.borderWidth    = 0.5
        self.clipsToBounds        = true
    }

    func uncropRedProfile(radius: CGFloat? = nil) {
        self.layer.cornerRadius   = 0
        self.layer.borderColor    = UIColor.clear.cgColor
        self.layer.borderWidth    = 0.0
        self.clipsToBounds        = false
    }

    func makeCircle () {
        layer.cornerRadius = 0.5 * frame.size.width
        clipsToBounds = true
    }
}
