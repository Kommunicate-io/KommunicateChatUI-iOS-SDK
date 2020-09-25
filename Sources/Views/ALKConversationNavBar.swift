//
//  ALKConversationNavBar.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 25/02/19.
//

import Foundation
import Kingfisher

@objc public protocol NavigationBarCallbacks: AnyObject {
    @objc func titleTapped()
}

open class ALKConversationNavBar: UIView, Localizable {
    let configuration: ALKConfiguration
    weak var delegate: NavigationBarCallbacks?
    open var disableTitleAction: Bool = false

    var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    var profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    lazy var statusIconBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    var onlineStatusIcon: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(165, green: 170, blue: 165)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    var onlineStatusText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(113, green: 110, blue: 110)
        return label
    }()

    lazy var profileView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.profileName, self.onlineStatusText])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.isHidden = true
        return stackView
    }()

    public required init(configuration: ALKConfiguration, delegate: NavigationBarCallbacks) {
        self.configuration = configuration
        self.delegate = delegate
        super.init(frame: .zero)
        setupConstraints()
        setupActions()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupAppearance(_ appearance: UINavigationBar) {
        if let textColor = appearance.titleTextAttributes?[.foregroundColor] as? UIColor {
            profileName.textColor = textColor
            onlineStatusText.textColor = textColor
        }
        if let titleFont = appearance.titleTextAttributes?[.font] as? UIFont {
            profileName.font = titleFont
        }
        if let subtitleFont = appearance.titleTextAttributes?[.secondaryFont] as? UIFont {
            onlineStatusText.font = subtitleFont
        }
    }

    func updateView(profile: ALKConversationProfile) {
        profileView.isHidden = false
        setupProfile(name: profile.name, imageUrl: profile.imageUrl, isContact: profile.status != nil)
        guard let status = profile.status, !profile.isBlocked else {
            hideStatus(true)
            return
        }
        hideStatus(false)
        updateStatus(isOnline: status.isOnline, lastSeenAt: status.lastSeenAt)
    }

    func updateStatus(isOnline: Bool, lastSeenAt: NSNumber?) {
        if isOnline {
            onlineStatusText.text = localizedString(forKey: "Online", withDefaultValue: SystemMessage.UserStatus.Online, fileName: configuration.localizedStringFileName)
            onlineStatusIcon.backgroundColor = UIColor(28, green: 222, blue: 20)
        } else {
            showLastSeen(lastSeenAt)
            onlineStatusIcon.backgroundColor = UIColor(165, green: 170, blue: 165)
        }
    }

    @objc func titleTapped() {
        guard !disableTitleAction else { return }
        delegate?.titleTapped()
    }

    private func setupConstraints() {
        statusIconBackground.addViewsForAutolayout(views: [onlineStatusIcon])
        addViewsForAutolayout(views: [profileImage, statusIconBackground, profileView])

        profileImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 35).isActive = true

        statusIconBackground.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 0).isActive = true
        statusIconBackground.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: -10).isActive = true
        statusIconBackground.widthAnchor.constraint(equalToConstant: 12).isActive = true
        statusIconBackground.heightAnchor.constraint(equalToConstant: 12).isActive = true

        onlineStatusIcon.centerXAnchor.constraint(equalTo: statusIconBackground.centerXAnchor).isActive = true
        onlineStatusIcon.centerYAnchor.constraint(equalTo: statusIconBackground.centerYAnchor).isActive = true
        onlineStatusIcon.widthAnchor.constraint(equalToConstant: 10).isActive = true
        onlineStatusIcon.heightAnchor.constraint(equalToConstant: 10).isActive = true

        profileView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 5).isActive = true
        profileView.topAnchor.constraint(equalTo: profileImage.topAnchor).isActive = true
        profileView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func hideStatus(_ hide: Bool) {
        statusIconBackground.isHidden = hide
        onlineStatusText.isHidden = hide
    }

    private func setupActions() {
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        tapAction.numberOfTapsRequired = 1
        profileView.addGestureRecognizer(tapAction)
    }

    private func setupProfile(name: String, imageUrl: String?, isContact: Bool) {
        profileName.text = name

        let placeholderName = isContact ? "contactPlaceholder" : "groupPlaceholder"
        let placeholder = UIImage(named: placeholderName, in: Bundle.applozic, compatibleWith: nil)
        guard
            let urlString = imageUrl,
            let url = URL(string: urlString)
        else {
            profileImage.image = placeholder
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        profileImage.kf.setImage(with: resource, placeholder: placeholder)
    }

    private func showLastSeen(_ lastSeenAt: NSNumber?) {
        guard let lastSeenAt = lastSeenAt else {
            onlineStatusText.isHidden = true
            return
        }
        let currentTime = Date()
        let lastSeen = Double(exactly: lastSeenAt) ?? 0.0
        let lastOnlineTime = Date(timeIntervalSince1970: lastSeen / 1000)
        let difference = currentTime.timeIntervalSince(lastOnlineTime)
        var status: String = ""
        if difference < 60.0 { // Less than 1 minute
            status = localizedString(forKey: "JustNow", withDefaultValue: SystemMessage.UserStatus.JustNow, fileName: configuration.localizedStringFileName)
        } else if difference < 60.0 * 60.0 { // Less than 1 hour
            let minutes = difference.truncatingRemainder(dividingBy: 3600) / 60
            let format = localizedString(forKey: "MinutesAgo",
                                         withDefaultValue: SystemMessage.UserStatus.MinutesAgo,
                                         fileName: configuration.localizedStringFileName)
            status = String(format: format, String(format: "%.0f", minutes))
        } else if difference < 60.0 * 60.0 * 24 { // Less than 1 day
            let hours = difference / 3600
            let format = localizedString(forKey: "HoursAgo",
                                         withDefaultValue: SystemMessage.UserStatus.HoursAgo,
                                         fileName: configuration.localizedStringFileName)
            status = String(format: format, String(format: "%.0f", hours))
        } else {
            let format = DateFormatter()
            format.dateFormat = "EE, MMM dd, yyy"
            status = format.string(from: lastOnlineTime)
        }
        let lastSeenFormat = localizedString(forKey: "LastSeen",
                                             withDefaultValue: SystemMessage.UserStatus.LastSeen,
                                             fileName: configuration.localizedStringFileName)
        onlineStatusText.text = String(format: lastSeenFormat, status)
    }
}
