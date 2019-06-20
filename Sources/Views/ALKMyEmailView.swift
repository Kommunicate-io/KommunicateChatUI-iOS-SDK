//
//  ALKMyEmailView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 14/03/19.
//

import Foundation

open class ALKMyEmailCell: UITableViewCell {

    struct Padding {
        struct StateView {
            static let top: CGFloat = 1
            static let right: CGFloat = 2
            static let width: CGFloat = 17.0
            static let height: CGFloat = 9.0
        }

        struct EmailView {
            static let trailing: CGFloat =  10
            static let leading: CGFloat =  70
        }

        struct TimeLabel {
            static let top: CGFloat =  1
            static let trailing: CGFloat = 2
            static let height: CGFloat =  25
        }
    }

    // MARK: - Properties

    lazy var emailView = ALKEmailView(frame: .zero)

    private var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.isOpaque = true
        return timeLabel
    }()

    lazy var emailViewHeight = emailView.heightAnchor.constraint(equalToConstant: ALKEmailView.rowHeight(nil))

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setupStyle()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods

    func update(viewModel: ALKMessageViewModel) {
        guard let emailMessage = viewModel.message else { return }
        emailView.loadWebView(with: emailMessage)
        timeLabel.text = viewModel.time

        // Set read status
        if viewModel.isAllRead {
            stateView.image = UIImage(named: "read_state_3", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor(netHex: 0x0578FF)
        } else if viewModel.isAllReceived {
            stateView.image = UIImage(named: "read_state_2", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else if viewModel.isSent {
            stateView.image = UIImage(named: "read_state_1", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = nil
        } else {
            stateView.image = UIImage(named: "seen_state_0", in: Bundle.applozic, compatibleWith: nil)
            stateView.tintColor = UIColor.red
        }
    }

    func updateHeight(_ height: CGFloat?) {
        emailView.updateHeight(height)
        emailViewHeight.constant = ALKEmailView.rowHeight(height)
    }

    class func rowHeight(viewModel: ALKMessageViewModel, height: CGFloat?) -> CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += Padding.TimeLabel.height + Padding.TimeLabel.top  /// time height
        totalHeight += ALKEmailView.rowHeight(height)
        return totalHeight
    }

    // MARK: - Private helper methods

    private func setupConstraints() {
        contentView.addViewsForAutolayout(views: [stateView, emailView, timeLabel])

        emailView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        emailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.EmailView.trailing).isActive = true
        emailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.EmailView.leading).isActive = true
        emailViewHeight.isActive = true

        stateView.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant:  Padding.StateView.top).isActive = true
        stateView.trailingAnchor.constraint(equalTo: emailView.leadingAnchor, constant: -1 * Padding.StateView.right).isActive = true
        stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height).isActive = true

        timeLabel.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -Padding.TimeLabel.trailing).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: Padding.TimeLabel.height).isActive = true
    }

    private func setupStyle() {
        contentView.backgroundColor = UIColor.clear
        timeLabel.setStyle(ALKMessageStyle.time)
    }

}
