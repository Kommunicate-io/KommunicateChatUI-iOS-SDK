//
//  KMChatInternalNoteCell.swift
//  KommunicateChatUI-iOS-SDK
//

import Foundation
import UIKit
import KommunicateCore_iOS_SDK

extension KMChatMessageViewModel {
    var internalNoteContent: String? {
        guard let metadata = metadata,
              metadata["NOTE_ID"] != nil,
              let noteContent = metadata["noteContent"] as? String,
              !noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }
        return noteContent
    }
}

final class KMChatInternalNoteCell: UITableViewCell, Localizable {
    enum Padding {
        static let horizontal: CGFloat = 16
        static let top: CGFloat = 6
        static let bottom: CGFloat = 6
        static let cardInset: CGFloat = 12
        static let badgeHeight: CGFloat = 22
        static let badgeHorizontalInset: CGFloat = 10
        static let badgeToNote: CGFloat = 8
        static let cardToTime: CGFloat = 4
        static let timeHeight: CGFloat = 16
    }

    private static let noteFont = UIFont.systemFont(ofSize: 15)

    private var localizedStringFileName = "Localizable"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xC8C6FF)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(netHex: 0x6C68E0).cgColor
        return view
    }()

    private let badgeLabel: UILabel = {
        let label = KMChatInternalNoteBadgeLabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textColor = UIColor(netHex: 0x5553B7)
        label.backgroundColor = UIColor(netHex: 0xB0ADF5)
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = KMChatInternalNoteCell.noteFont
        label.textColor = UIColor(netHex: 0x3A3A55)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(netHex: 0x737373)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLocalizedStringFileName(_ fileName: String) {
        localizedStringFileName = fileName
    }

    func update(viewModel: KMChatMessageViewModel) {
        badgeLabel.text = localizedString(forKey: "InternalNoteBadge", withDefaultValue: "Note", fileName: localizedStringFileName)
        noteLabel.text = viewModel.internalNoteContent
        timeLabel.text = viewModel.time
    }

    static func rowHeight(viewModel: KMChatMessageViewModel, width: CGFloat) -> CGFloat {
        let noteWidth = width - 2 * (Padding.horizontal + Padding.cardInset)
        let noteHeight = (viewModel.internalNoteContent ?? "").boundingRect(
            with: CGSize(width: max(noteWidth, 0), height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: noteFont],
            context: nil
        ).height
        return Padding.top + Padding.cardInset + Padding.badgeHeight + Padding.badgeToNote
            + ceil(noteHeight) + Padding.cardInset + Padding.cardToTime + Padding.timeHeight + Padding.bottom
    }

    private func setupConstraints() {
        cardView.addViewsForAutolayout(views: [badgeLabel, noteLabel])
        contentView.addViewsForAutolayout(views: [cardView, timeLabel])

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Padding.top),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Padding.horizontal),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Padding.horizontal),

            badgeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Padding.cardInset),
            badgeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Padding.cardInset),
            badgeLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -Padding.cardInset),
            badgeLabel.heightAnchor.constraint(equalToConstant: Padding.badgeHeight),

            noteLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: Padding.badgeToNote),
            noteLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Padding.cardInset),
            noteLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Padding.cardInset),
            noteLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Padding.cardInset),

            timeLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: Padding.cardToTime),
            timeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: Padding.timeHeight)
        ])
    }
}

private final class KMChatInternalNoteBadgeLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 2 * KMChatInternalNoteCell.Padding.badgeHorizontalInset, height: size.height)
    }
}
