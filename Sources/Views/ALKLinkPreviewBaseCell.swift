import Foundation
import KommunicateCore_iOS_SDK
#if canImport(RichMessageKit)
    import RichMessageKit
#endif
class ALKLinkPreviewBaseCell: ALKMessageCell {
    var url: String?
    let linkView = ALKLinkView()

    override func update(
        viewModel: ALKMessageViewModel,
        messageStyle: Style,
        mentionStyle: Style
    ) {
        super.update(viewModel: viewModel, messageStyle: messageStyle, mentionStyle: mentionStyle)
        linkView.setLocalizedStringFileName(localizedStringFileName)
        url = ALKLinkPreviewManager.extractURLAndAddInCache(from: viewModel.message, identifier: viewModel.identifier)?.absoluteString
    }

    override func setupViews() {
        super.setupViews()
        contentView.addViewsForAutolayout(views:
            [linkView])
        contentView.bringSubviewToFront(linkView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openUrl))
        linkView.frontView.addGestureRecognizer(tapGesture)
        messageView.delegate = self
    }

    override func setupStyle() {
        super.setupStyle()
    }

    override class func messageHeight(viewModel: ALKMessageViewModel,
                                      width: CGFloat, font: UIFont, mentionStyle: Style,
                                      displayNames: ((Set<String>) -> ([String: String]?))?) -> CGFloat
    {
        return super.messageHeight(viewModel: viewModel, width: width, font: font, mentionStyle: mentionStyle, displayNames: displayNames)
    }

    @objc private func openUrl() {
        guard let stringURL = url, let openURL = URL(string: stringURL) else { return }
        UIApplication.sharedUIApplication()?.open(openURL)
    }

    func isCellVisible(_ closure: @escaping ((_ identifier: String) -> Bool)) {
        linkView.isViewCellVisible = closure
    }
    
    // To show Menu Controller if user long presses the Link
    func showMenuControllerForLink(_ gestureView : UIView) {
        NotificationCenter.default.addObserver(self, selector: #selector(menuWillShow(_:)), name: UIMenuController.willShowMenuNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuWillHide(_:)), name: UIMenuController.willHideMenuNotification, object: nil)

        guard let superView = gestureView.superview else {return}
        
        let menuController = UIMenuController.shared

        guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else {
            return
        }

        gestureView.becomeFirstResponder()

        var menus: [UIMenuItem] = []

        if let copyMenu = getCopyMenuItem(copyItem: self) {
            menus.append(copyMenu)
        }

        if let replyMenu = getReplyMenuItem(replyItem: self) {
            menus.append(replyMenu)
        }

        if showReport, let reportMessageMenu = getReportMessageItem(reportMessageItem: self) {
            menus.append(reportMessageMenu)
        }

        menuController.menuItems = menus
        menuController.setTargetRect(gestureView.frame, in: superView)
        menuController.setMenuVisible(true, animated: true)
    }
}
extension ALKLinkPreviewBaseCell: UITextViewDelegate {
    public func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let message = viewModel else { return true }
        // Check for interaction type then proceed. 0 -> Tap , 1 -> Longpress
        if interaction.rawValue == 0 {
            delegate?.urlTapped(url: URL, message: message)
        } else if interaction.rawValue == 1 {
            showMenuControllerForLink(self)
        }
        return false
    }
}
