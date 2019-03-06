//
//  ALKLoadingIndicator.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 06/03/19.
//

import UIKit

public class ALKLoadingIndicator: UIStackView, Localizable {

    // MARK: - Properties

    var activityIndicator = UIActivityIndicatorView(style: .gray)

    var loadingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Initializer

    public init(frame: CGRect, color: UIColor, localizationFileName: String) {
        super.init(frame: frame)
        loadingLabel.text = localizedString(forKey: "LoadingIndicatorText", withDefaultValue: SystemMessage.Information.LoadingIndicatorText, fileName: localizationFileName)
        setupStyle(color)
        setupView()
        self.isHidden = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    public func startLoading() {
        self.isHidden = false
        activityIndicator.startAnimating()
    }

    public func stopLoading() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }

    // MARK: - Private helper methods

    private func setupStyle(_ color: UIColor) {
        activityIndicator.color = color
        loadingLabel.textColor = color
    }

    private func setupView() {
        self.axis = .horizontal
        self.alignment = .center
        self.distribution = .fill
        self.spacing = 10
        self.addArrangedSubview(activityIndicator)
        self.addArrangedSubview(loadingLabel)
    }
}
