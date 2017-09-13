//
//  DateSectionHeaderView.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class ALKDateSectionHeaderView: UIView {

    // MARK: - Variables and Types
    // MARK: ChatDate
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dateView: UIView! {
        didSet {
            dateView.layer.cornerRadius = dateView.frame.size.height / 2.0
        }
    }
    
    // MARK: - Lifecycle
    class func instanceFromNib() -> ALKDateSectionHeaderView {
//        guard let view = UINib(nibName: DateSectionHeaderView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? DateSectionHeaderView else {
//            fatalError("\(DateSectionHeaderView.nibName) don't existing")
//        }

        return UIView() as! ALKDateSectionHeaderView
    }
    
    // MARK: - Methods of class
    // MARK: ChatDate
    func setupDate(withDateFormat date: String) {
        self.dateLabel.text = date
    }

}
