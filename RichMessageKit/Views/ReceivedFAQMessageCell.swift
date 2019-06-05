//
//  ReceivedFAQMessageCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/06/19.
//

import UIKit

public class ReceivedFAQMessageCell: UITableViewCell {

    public struct Config {
        public static var padding = Padding(left: 10, right: 60, top: 10, bottom: 10)
        public static var maxWidth = UIScreen.main.bounds.width
        public static var faqTopPadding: CGFloat = 4
        public static var faqRightPadding: CGFloat = 20
    }

    // MARK: Fileprivate properties

    fileprivate lazy var messageView = ReceivedMessageView(
        frame: .zero,
        padding: messageViewPadding,
        maxWidth: Config.maxWidth)

    fileprivate lazy var faqView = FAQMessageView(
        frame: .zero,
        faqStyle: FAQMessageTheme.receivedMessage,
        alignLeft: true)

    fileprivate var messageViewPadding: Padding

    fileprivate lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    static var faqWidth = Config.maxWidth - Config.faqRightPadding
        - (Config.padding.left
        + ReceivedMessageView.Config.ProfileImage.width
        + ReceivedMessageView.Config.MessageView.leftPadding)

    public var faqSelected: ((_ index: Int?, _ title: String) -> Void)? {
        didSet {
            faqView.faqSelected = faqSelected
        }
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageViewPadding = Padding(left: Config.padding.left,
                                     right: Config.padding.right,
                                     top: Config.padding.top,
                                     bottom: Config.faqTopPadding)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK:- Public methods

    public func update(model: FAQMessage) {
        guard !model.message.isMyMessage else {
            print("😱😱😱Inconsistent information passed to the view.😱😱😱")
            print("For Received view isMyMessage should be false")
            return
        }
        messageView.update(model: model.message)
        messageViewHeight.constant = ReceivedMessageView.rowHeight(model: model.message, maxWidth: Config.maxWidth, padding: messageViewPadding)

        faqView.update(model: model, maxWidth: ReceivedFAQMessageCell.faqWidth)
        /// Set frame
        let height = ReceivedFAQMessageCell.rowHeight(model: model)
        self.frame.size = CGSize(width: Config.maxWidth, height: height)
    }

    public class func rowHeight(model: FAQMessage) -> CGFloat {
        return FAQMessageSizeCalculator().rowHeight(model: model, maxWidth: Config.maxWidth, padding: Config.padding)
    }

    //MARK:- Private helper methods

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [messageView, faqView])
        let leadingMargin =
            Config.padding.left
                + ReceivedMessageView.Config.ProfileImage.width
                + ReceivedMessageView.Config.MessageView.leftPadding
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: self.topAnchor),
            messageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            messageViewHeight,

            faqView.topAnchor.constraint(equalTo: messageView.bottomAnchor),
            faqView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingMargin),
            faqView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Config.faqRightPadding),
            faqView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * Config.padding.bottom)
            ])
    }

}
