//
//  ALKQuickReplyCell.swift
//  ApplozicSwift
//
//  Created by apple on 10/07/18.
//

import Foundation

open class ALKFriendMessageQuickReplyCell: ALKFriendMessageCell {
    
    open var collectionView: ALKIndexedCollectionView!
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
       let frame = self.contentView.bounds
       collectionView.frame = CGRect(x: 0, y: 5.0, width: frame.size.width, height: frame.size.height - 5.0)
    }
    
    open class func rowHeightFor() -> CGFloat {
        let elementHeight = 60
        let buttonHeight = 30
        return CGFloat(buttonHeight + elementHeight)
    }
    
    override func setupViews() {
        super.setupViews()
        setupCollectionView()

    }
    
    override open func update(viewModel: ALKMessageViewModel) {
        super.update(viewModel: viewModel)
        self.viewModel = viewModel
        collectionView.setMessage(viewModel: viewModel)
        collectionView.reloadData()
    }
    
    public class func rowHeightFor(message: ALKMessageViewModel) -> CGFloat {
        
        // Update height based on number of buttons
        // present and if image is set.
        return ALKIndexedCollectionView.rowHeightFor(message:message)
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
    
    open func updateCollectionView() {
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 90, left: 10, bottom: 5, right: 5)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 91, height: 91)
        layout.scrollDirection = .horizontal
        collectionView = ALKIndexedCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = true
        contentView.insertSubview(collectionView, at: 0)
    }
}

