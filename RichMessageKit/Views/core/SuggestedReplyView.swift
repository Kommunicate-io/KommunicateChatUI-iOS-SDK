//
//  SuggestedReplyView.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 18/01/19.
//

import UIKit

/// It's a staggered grid view of buttons.
///
/// Use `alignLeft` property to align the buttons to left or right side.
/// Use `maxWidth` property if view has to be constrained with some maximum width.
/// Pass custom `SuggestedReplyConfig` to modify font and color of view.
/// - NOTE: It uses an array of dictionary where each dictionary should have `title` key which will be used as button text.
public class SuggestedReplyView: UIView {
    // MARK: Public properties

    // MARK: Internal properties

    // This is used to align the view to left or right. Gets value from message.isMyMessage
    var alignLeft: Bool = true
    weak var delegate: Tappable?

    var model: SuggestedReplyMessage?

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: Initializers

    /// Initializer for `SuggestedReplyView`
    ///
    /// - Parameters:
    ///   - maxWidth: Max Width to constrain view.
    /// Gives information about the title and index of quick reply selected. Indexing starts from 1.
    public init() {
        super.init(frame: .zero)
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public methods

    /// Creates Suggested reply buttons using dictionary.
    ///
    /// - Parameter - model: Object that conforms to `SuggestedReplyMessage`.
    public func update(model: SuggestedReplyMessage, maxWidth: CGFloat) {
        self.model = model
        /// Set frame size.
        let width = maxWidth
        let height = SuggestedReplyView.rowHeight(model: model, maxWidth: width)
        let size = CGSize(width: width, height: height)
        frame.size = size

        alignLeft = !model.message.isMyMessage

        setupSuggestedReplyButtons(model, maxWidth: maxWidth)
    }

    /// It calculates height of `SuggestedReplyView` based on the dictionary passed.
    ///
    /// - NOTE: Padding is not used.
    /// - Parameters:
    ///   - model: Object that conforms to `SuggestedReplyModel`.
    ///   - maxWidth: MaxWidth to constrain view. pass same value used while initialization.
    ///   - font: Font for suggested replies. Pass the custom SuggestedReplyConfig font used while initialization.
    /// - Returns: Returns height of view based on passed parameters.
    public static func rowHeight(model: SuggestedReplyMessage,
                                 maxWidth: CGFloat) -> CGFloat
    {
        return SuggestedReplyViewSizeCalculator().rowHeight(model: model, maxWidth: maxWidth)
    }

    // MARK: Private methods

    private func setupConstraints() {
        addViewsForAutolayout(views: [mainStackView])
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func setupSuggestedReplyButtons(_ suggestedMessage: SuggestedReplyMessage, maxWidth: CGFloat) {
        mainStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        var width: CGFloat = 0
        var subviews = [UIView]()
        // A Boolean value to indicate whether the suggested replies span over more than 1 line.
        // Usage: We add hidden view to horizontal stackview due to the bug in stackview which causes subviews to
        // expand to cover total width.Change In case there is just 1 line, then it's probably
        // a better idea to just restrict the total width of stackview to the minimal required width rather than
        // bluntly adding hidden view all the time.
        var isMultiLine = false
        for index in 0 ..< suggestedMessage.suggestion.count {
            let title = suggestedMessage.suggestion[index].title
            let type = suggestedMessage.suggestion[index].type
            var button: CurvedImageButton!
            if type == .link {
                let image = UIImage(named: "link", in: Bundle.richMessageKit, compatibleWith: nil)
                button = curvedButton(title: title, image: image, index: index, maxWidth: maxWidth)
            } else {
                button = curvedButton(title: title, image: nil, index: index, maxWidth: maxWidth)
            }
            width += button.buttonWidth() + 10 // Button Padding

            if width >= maxWidth {
                isMultiLine = true
                guard !subviews.isEmpty else {
                    let stackView = horizontalStackView(subviews: [button])
                    mainStackView.addArrangedSubview(stackView)
                    width = 0
                    continue
                }
                let hiddenView = hiddenViewUsing(currWidth: width - button.buttonWidth(), maxWidth: maxWidth, subViews: subviews)
                alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
                width = button.buttonWidth() + 10
                let stackView = horizontalStackView(subviews: subviews)
                mainStackView.addArrangedSubview(stackView)
                subviews.removeAll()
                subviews.append(button)
            } else {
                subviews.append(button)
            }
        }
        let hiddenView = hiddenViewUsing(currWidth: width, maxWidth: maxWidth, subViews: subviews)

        if isMultiLine {
            alignLeft ? subviews.append(hiddenView) : subviews.insert(hiddenView, at: 0)
        }

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

    private func hiddenViewUsing(currWidth: CGFloat, maxWidth: CGFloat, subViews _: [UIView]) -> UIView {
        let unusedWidth = maxWidth - currWidth - 20
        let height = (subviews[0] as? CurvedImageButton)?.buttonHeight() ?? 0
        let size = CGSize(width: unusedWidth, height: height)

        let view = UIView()
        view.backgroundColor = .clear
        view.frame.size = size
        return view
    }

    private func curvedButton(title: String, image: UIImage?, index: Int, maxWidth: CGFloat) -> CurvedImageButton {
        let button = CurvedImageButton(title: title, image: image, maxWidth: maxWidth)
        button.delegate = self
        button.index = index
        return button
    }
}

extension SuggestedReplyView: Tappable {
    public func didTap(index: Int?, title: String) {
        guard let index = index, let suggestion = model?.suggestion[index] else { return }
        let replyToBeSend = suggestion.reply ?? title
        delegate?.didTap(index: index, title: replyToBeSend)
    }
}
