//
//  ALKMyGenericCardCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 05/12/18.
//

import Foundation
import Applozic

class ALKMyGenericCardCell: ALKChatBaseCell<ALKMessageViewModel> {
    
    open var collectionView: ALKGenericCardCollectionView!
    
    var height: CGFloat!
    private var widthPadding: CGFloat = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
    
    fileprivate lazy var messageView: ALHyperLabel = {
        let label = ALHyperLabel.init(frame: .zero)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()
    
    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()
    
    fileprivate var bubbleView: UIImageView = {
        let bv = UIImageView()
        let image = UIImage.init(named: "chat_bubble_rounded", in: Bundle.applozic, compatibleWith: nil)
        bv.tintColor = UIColor(netHex: 0xF1F0F0)
        bv.image = image?.imageFlippedForRightToLeftLayoutDirection()
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
        collectionView.setMessage(viewModel: viewModel)
        collectionView.reloadData()
        
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.message)
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)
        
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
    
    override func setupViews() {
        setupCollectionView()
        
        contentView.addViewsForAutolayout(views: [self.collectionView, self.messageView, self.bubbleView, timeLabel, stateView])
        contentView.bringSubview(toFront: messageView)
        
        messageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 95).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
        messageView.heightAnchor.constraint(lessThanOrEqualToConstant: 1000).isActive = true
        messageView.layoutIfNeeded()
        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 8).isActive = true
        
        stateView.widthAnchor.constraint(equalToConstant: 17.0).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: 9.0).isActive = true
        stateView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -1.0).isActive = true
        stateView.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -2.0).isActive = true

        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -2.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 2).isActive = true
        
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 85).isActive = true
        collectionView.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 10).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }
    
    public class func rowHeightFor(message: ALKMessageViewModel) -> CGFloat {
        // Update height based on number of buttons
        // present and if image is set.
        return ALKGenericCardCollectionView.rowHeightFor(message:message) + GenericCardsMessageView.rowHeigh(viewModel: message, widthNoPadding: UIScreen.main.bounds.width - 130) - 20
    }
    
    open func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, index: NSInteger) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.tag = index
        collectionView.reloadData()
    }
    
    open func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, indexPath: IndexPath) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.indexPath = indexPath
        collectionView.tag = indexPath.section
        collectionView.reloadData()
    }
    
    open func register(cell: UICollectionViewCell.Type) {
        collectionView.register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
    
    private func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = ALKGenericCardCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
}
