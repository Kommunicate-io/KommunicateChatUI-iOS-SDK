//
//  ALQuickReplyCollectionViewCell.swift
//  ApplozicSwift
//
//  Created by apple on 12/07/18.
//

import Foundation
import Applozic

open class ALKQuickReplyCollectionView: ALKIndexedCollectionView {
    
    open var cardTemplate: [Dictionary<String,Any>]?
    
    override open func setMessage(viewModel: ALKMessageViewModel) {
        super.setMessage(viewModel: viewModel)
    }
    
    override open class func rowHeightFor(message: ALKMessageViewModel) -> CGFloat {
        
        return ALQuickReplyCollectionViewCell.rowHeightFor()
    }
    
}

open class ALQuickReplyCollectionViewCell: UICollectionViewCell {
    
    public enum Padding {
        enum ButtonView {
            static var top: CGFloat = 5.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = -5.0
            static var height: CGFloat = 80.0
        }
    }
    
    open var buttonSelected: ((_ index: Int, _ name: String)->())?
    
    open var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray, for: .normal)
        button.isUserInteractionEnabled = true
        button.setFont(font: UIFont.font(.bold(size: 14.0)))
        button.setTitle("Button", for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1
        button.isUserInteractionEnabled = true
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    func setupUI() {
        contentView.isUserInteractionEnabled = true
        contentView.addViewsForAutolayout(views: [button])
        contentView.bringSubview(toFront:button)
        self.setUpButtonConstraints()
    }
    
    func setUpButtonConstraints() {
        button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Padding.ButtonView.left).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    open var descriptionLabelHeight: CGFloat = 80.0
    open var titleLabelStackViewHeight: CGFloat = 50.0
    
    open var actionUIButtons = [UIButton]()
    
    var jsonArray: [Dictionary<String,Any>]!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open class func rowHeightFor() -> CGFloat {
        let baseHeight:CGFloat = 170
        let padding:CGFloat = 10
        return baseHeight  + padding
    }
    
    open func update(data: Dictionary<String,Any>) {
        updateViewFor(data)
    }
    
    @objc func buttonSelected(_ sender: UIButton) {
        self.sendMessage(sender)
    }
    
    private func updateViewFor(_ jsonArray: Dictionary<String,Any>) {
        button.setTitle(jsonArray["title"] as? String, for: .normal)
    }
    
    func sendMessage(_ sender: UIButton) {
      self.buttonSelected?(sender.tag, sender.currentTitle ?? "")
    }
    
}


