//
//  ALQuickReplyCollectionViewCell.swift
//  ApplozicSwift
//
//  Created by apple on 12/07/18.
//

import Foundation


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
        enum CoverImageView {
            static var top: CGFloat = 5.0
            static var left: CGFloat = 5.0
            static var right: CGFloat = -5.0
            static var height: CGFloat = 80.0
        }
        enum mainStackView {
            static var bottom: CGFloat = -20.0
            static var left: CGFloat = 0
            static var right: CGFloat = 0
        }
    }
    
    func setupUI() {
        let view = contentView
        view.addViewsForAutolayout(views: [button])
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Padding.CoverImageView.left).isActive = true
        button.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    open let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray, for: .normal)
        button.isUserInteractionEnabled = true
        button.setFont(font: UIFont.font(.bold(size: 14.0)))
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action: #selector(buttonSelected(_:)), for: .touchUpInside)
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    

    open var descriptionLabelHeight: CGFloat = 80.0
    open var titleLabelStackViewHeight: CGFloat = 50.0
    
    open var actionUIButtons = [UIButton]()
    open var card: ALKGenericCard!
    
    var jsonArray: [Dictionary<String,Any>]!
    
    open var buttonSelected: ((_ index: Int, _ name: String)->())?
    
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
    
    @objc func buttonSelected(_ action: UIButton) {
        self.buttonSelected?(action.tag, action.titleLabel?.text ?? "")
    }

    
    private func updateViewFor(_ jsonArray: Dictionary<String,Any>) {
        button.setTitle(jsonArray["title"] as? String, for: .normal)

    }
  
}


