//
//  KMChatDateSectionHeaderView.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import UIKit

class KMChatDateSectionHeaderView: UIView {
    // MARK: - Variables and Types

    // MARK: ChatDate

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dateView: UIView! {
        didSet {
            dateView.layer.cornerRadius = dateView.frame.size.height / 2.0
        }
    }

    // MARK: - Lifecycle

    class func instanceFromNib() -> KMChatDateSectionHeaderView {
        guard let view = UINib(nibName: KMChatDateSectionHeaderView.nibName, bundle: Bundle.km).instantiate(withOwner: nil, options: nil).first as? KMChatDateSectionHeaderView else {
            fatalError("\(KMChatDateSectionHeaderView.nibName) don't existing")
        }
        return view
    }

    // MARK: - Methods of class

    // MARK: ChatDate

    func setupDate(withDateFormat date: String) {
        dateLabel.text = date
    }

    func setupViewStyle() {
        backgroundColor = UIColor.clear
        let dateCellStyle = KMChatMessageStyle.dateSeparator
        dateView.backgroundColor = dateCellStyle.background
        dateLabel.backgroundColor = dateCellStyle.background
        dateLabel.textColor = dateCellStyle.text
        dateLabel.setFont(dateCellStyle.font)
    }
}
