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

    public init(frame: CGRect, color: UIColor = .black) {
        super.init(frame: frame)
        set(color)
        setupView()
        isHidden = true
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    public func startLoading(localizationFileName: String) {
        loadingLabel.text = localizedString(forKey: "LoadingIndicatorText", withDefaultValue: SystemMessage.Information.LoadingIndicatorText, fileName: localizationFileName)
        isHidden = false
        activityIndicator.startAnimating()
    }

    public func stopLoading() {
        isHidden = true
        activityIndicator.stopAnimating()
    }

    public func set(_ color: UIColor) {
        activityIndicator.color = color
        loadingLabel.textColor = color
    }

    // MARK: - Private helper methods

    private func setupView() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 10
        addArrangedSubview(activityIndicator)
        addArrangedSubview(loadingLabel)
    }
}
