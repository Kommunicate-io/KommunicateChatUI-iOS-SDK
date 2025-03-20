//
//  KMBusinessHoursView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 17/03/25.
//

import Foundation
import UIKit

open class KMBusinessHoursView: UIView {
    private let businessHourMessageLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        return label
    }()
    
    private var lineImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "line", in: Bundle.km, compatibleWith: nil))
        return imageView
    }()
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        let view = self
        view.addViewsForAutolayout(views: [lineImageView, businessHourMessageLabel])
        
        NSLayoutConstraint.activate([
            lineImageView.topAnchor.constraint(equalTo: view.topAnchor),
            lineImageView.heightAnchor.constraint(equalToConstant: 2),
            lineImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Title Label
            businessHourMessageLabel.topAnchor.constraint(equalTo: lineImageView.topAnchor),
            businessHourMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            businessHourMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            businessHourMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func configureMessage(message: String) {
        businessHourMessageLabel.text = message
        businessHourMessageLabel.font = Font.bold(size: 16.0).font()
        businessHourMessageLabel.textColor = .white
        lineImageView.backgroundColor = .white
    }
    
    public func estimateHeightForMessage(_ message: String) -> CGFloat {
        if message.isEmpty {
            return 0
        }
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Font.bold(size: 16.0).font()
        label.text = message
        let maxWidth = UIScreen.main.bounds.width - 30 // Considering leading & trailing padding
        let estimatedSize = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        return estimatedSize.height + 20 // Adding padding
    }
}
