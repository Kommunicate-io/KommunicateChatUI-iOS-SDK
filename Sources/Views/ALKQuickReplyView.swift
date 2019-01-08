//
//  ALKQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 07/01/19.
//
struct QuickReplySettings {
    static let font = UIFont.systemFont(ofSize: 14)
    static let maxWidth = UIScreen.main.bounds.width - 100
}

class ALKQuickReplyView: UIView {

    let font = QuickReplySettings.font
    let maxWidth = QuickReplySettings.maxWidth

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(quickReplyArray: [Dictionary<String, Any>]) {
        setupQuickReplyButtons(quickReplyArray)
    }

    class func rowHeight(quickReplyArray: [Dictionary<String, Any>]) -> CGFloat {
        let font = QuickReplySettings.font
        let maxWidth = QuickReplySettings.maxWidth
        var currWidth: CGFloat
        var width: CGFloat = 0
        // Height of first item to start
        var height = ALKCurvedButton.buttonSize(text: quickReplyArray[0]["title"] as? String ?? "", maxWidth: maxWidth, font: font).height // spacing

        for dict in quickReplyArray {
            let title = dict["title"] as? String ?? ""
            let size = ALKCurvedButton.buttonSize(text: title, maxWidth: maxWidth, font: font)
            currWidth = size.width
            if width + currWidth > maxWidth {
                width = currWidth
                height += size.height + 10
            } else {
                width += currWidth + 10 //spacing
            }
        }
        return height
    }

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [mainStackView])
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    private func setupQuickReplyButtons(_ quickReplyArray: [Dictionary<String, Any>]) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        var width: CGFloat = 0
        var subviews = [UIView]()
        for quickReply in quickReplyArray {
            guard let title = quickReply["title"] as? String else {
                continue
            }
            let button = ALKCurvedButton(title: title, font: font, maxWidth: maxWidth)
            width += button.buttonWidth()

            if width >= maxWidth {
                guard subviews.count > 0 else {
                    let stackView = horizontalStackView(subviews: [button])
                    mainStackView.addArrangedSubview(stackView)
                    width = 0
                    continue
                }
                let hiddenView = hiddenViewUsing(currWidth: width - button.buttonWidth(), maxWidth: maxWidth, subViews: subviews)
                subviews.append(hiddenView)
                width = button.buttonWidth()
                let stackView = horizontalStackView(subviews: subviews)
                mainStackView.addArrangedSubview(stackView)
                subviews.removeAll()
                subviews.append(button)
            } else {
                width += 10
                subviews.append(button)
            }
        }
        let hiddenView = hiddenViewUsing(currWidth: width, maxWidth: maxWidth, subViews: subviews)
        subviews.append(hiddenView)
        let stackView = horizontalStackView(subviews: subviews)
        mainStackView.addArrangedSubview(stackView)
    }

    private func horizontalStackView(subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }

    private func hiddenViewUsing(currWidth: CGFloat, maxWidth: CGFloat, subViews: [UIView]) -> UIView {
        let unusedWidth = maxWidth - currWidth - 20
        let height = (subviews[0] as? ALKCurvedButton)?.buttonHeight() ?? 0
        let size = CGSize(width: unusedWidth, height: height)

        let view = UIView()
        view.backgroundColor = .clear
        view.frame.size = size
        return view
    }
}
