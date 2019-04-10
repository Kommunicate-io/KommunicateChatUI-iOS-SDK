//
//  QuickReplyView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import UIKit

/// It's a staggered grid view of buttons.
///
/// Use `alignLeft` property to align the buttons to left or right side.
/// Use `maxWidth` property if view has to be constrained with some maximum width.
/// Pass custom `QuickReplyConfig` to modify font and color of view.
/// - NOTE: It uses an array of dictionary where each dictionary should have `title` key which will be used as button text.
public class QuickReplyView: UIView, ViewInterface {

    // MARK: Public properties

    /// Configuration for QuickReplyView.
    /// It will configure font and color of quick reply buttons.
    public struct QuickReplyConfig {
        public var font = UIFont.systemFont(ofSize: 14)
        public var color = UIColor(red: 85, green: 83, blue: 183)
        public init() { }
    }

    // MARK: Internal properties

    let alignLeft: Bool
    let maxWidth: CGFloat
    let font: UIFont
    let color: UIColor
    let delegate: Tappable?

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: Initializers

    /// Initializer for `QuickReplyView`
    ///
    /// - Parameters:
    ///   - maxWidth: Max Width to constrain view.
    ///   - alignLeft: Use this to align the view to left or right.
    ///   - delegate: It is used to inform the delegate when quick reply is selected. Gives information about the title and index of quick reply selected. Indexing starts from 1.
    public init(maxWidth: CGFloat = UIScreen.main.bounds.width,
                alignLeft: Bool = true,
                config: QuickReplyConfig = QuickReplyConfig(),
                delegate: Tappable) {
        self.maxWidth = maxWidth
        self.alignLeft = alignLeft
        self.font = config.font
        self.color = config.color
        self.delegate = delegate
        super.init(frame: .zero)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// Creates Quick reply buttons using dictionary.
    ///
    /// - Parameter - model: Object that conforms to `QuickReplyModel`.
    public func update(model: QuickReplyModel) {
        /// Set frame size.
        let width = maxWidth
        let height = QuickReplyView.rowHeight(model: model, maxWidth: width, font: font)
        let size = CGSize(width: width, height: height)
        self.frame.size = size

        setupQuickReplyButtons(model)
    }

    /// It calculates height of `QuickReplyView` based on the dictionary passed.
    ///
    /// - NOTE: Padding is not used.
    /// - Parameters:
    ///   - model: Object that conforms to `QuickReplyModel`.
    ///   - maxWidth: MaxWidth to constrain view. pass same value used while initialization.
    ///   - font: Font for quick replies. Pass the custom QuickReplyConfig font used while initialization.
    /// - Returns: Returns height of view based on passed parameters.
    public static func rowHeight(model: QuickReplyModel,
                                maxWidth: CGFloat = UIScreen.main.bounds.width,
                                font: UIFont = QuickReplyConfig().font,
                                padding: Padding? = nil) -> CGFloat {
        return QuickReplyViewSizeCalculator().rowHeight(model: model, maxWidth: maxWidth, font: font)
    }

    // MARK: Private methods

    private func setupConstraints() {
        self.addViewsForAutolayout(views: [mainStackView])
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    private func setupQuickReplyButtons(_ model: QuickReplyModel) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        var width: CGFloat = 0
        var subviews = [UIView]()
        for index in 0 ..< model.title.count {
            let title = model.title[index]
            let button = curvedButton(title: title, index: index)
            width += button.buttonWidth()

            if width >= maxWidth {
                guard subviews.count > 0 else {
                    let stackView = horizontalStackView(subviews: [button])
                    mainStackView.addArrangedSubview(stackView)
                    width = 0
                    continue
                }
                let hiddenView = hiddenViewUsing(currWidth: width - button.buttonWidth(), maxWidth: maxWidth, subViews: subviews)
                alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
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
        alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
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
        let height = (subviews[0] as? CurvedButton)?.buttonHeight() ?? 0
        let size = CGSize(width: unusedWidth, height: height)

        let view = UIView()
        view.backgroundColor = .clear
        view.frame.size = size
        return view
    }

    private func curvedButton(title: String, index: Int) -> CurvedButton {
        let button = CurvedButton(title: title, delegate: self, font: font, color: color, maxWidth: maxWidth)
        button.index = index
        return button
    }
}

extension QuickReplyView: Tappable {
    public func didTap(index: Int?, title: String) {
        delegate?.didTap(index: index, title: title)
    }
}
