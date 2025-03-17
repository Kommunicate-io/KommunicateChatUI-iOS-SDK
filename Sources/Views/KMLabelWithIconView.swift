//
//  KMLabelWithIconView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 19/08/24.
//

import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

class KMLabelWithIconView: UIView {
    var urlLink: String?

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 1
        lbl.textColor = .gray
        lbl.lineBreakMode = .byTruncatingTail
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()

    private let iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "link", in: Bundle.km, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = .black
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        addSubview(label)
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            // Label Constraints
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 8),
            
            // Icon Constraints
            iconImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 13),
            iconImageView.heightAnchor.constraint(equalToConstant: 13),
            
            // Height Constraint
            self.heightAnchor.constraint(equalToConstant: 16),
            self.widthAnchor.constraint(equalToConstant: 250)
        ])
    }

    func configure(withText text: String, withURL url: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))

        label.attributedText = attributedString
        self.urlLink = url
    }
}
