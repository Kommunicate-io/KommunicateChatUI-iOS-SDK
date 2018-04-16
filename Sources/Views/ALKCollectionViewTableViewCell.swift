//
//  ALKCollectionTableViewCell.swift
//
//  Created by Mukesh on 09/04/18.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

open class ALKIndexedCollectionView: UICollectionView {

    open var indexPath: IndexPath!
    open var viewModel: ALKMessageViewModel?

    required override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open class func rowHeightFor(message: ALKMessageViewModel) -> CGFloat {
        //This should be overridden
        return 0
    }

    open func setMessage(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
    }
}

let collectionViewCellIdentifier: NSString = "CollectionViewCell"

open class ALKCollectionTableViewCell: ALKChatBaseCell<ALKMessageViewModel> {

    open var collectionView: ALKIndexedCollectionView!
    open var collectionViewType: ALKIndexedCollectionView.Type = ALKIndexedCollectionView.self

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.contentView.bounds
        collectionView.frame = CGRect(x: 0, y: 5.0, width: frame.size.width, height: frame.size.height - 5.0)
    }

    override open func update(viewModel: ALKMessageViewModel) {
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
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 91, height: 91)
        layout.scrollDirection = .horizontal
        collectionView = collectionViewType.init(frame: frame, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        let _ = contentView.subviews.map { $0.removeFromSuperview()}
        contentView.addSubview(self.collectionView)
        layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
    }
}
