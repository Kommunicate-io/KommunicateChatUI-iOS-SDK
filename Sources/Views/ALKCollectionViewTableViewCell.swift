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

    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open func setMessage(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
    }
}

let collectionViewCellIdentifier: NSString = "CollectionViewCell"

open class ALKCollectionTableViewCell: ALKChatBaseCell<ALKMessageViewModel> {

    open var collectionView: ALKIndexedCollectionView!
    open var collectionViewType: ALKIndexedCollectionView.Type = ALKIndexedCollectionView.self

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 4, left: 5, bottom: 4, right: 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 91, height: 91)
        layout.scrollDirection = .horizontal
        collectionView = ALKIndexedCollectionView.init(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .lightGray
        collectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(self.collectionView)
        layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.contentView.bounds
        collectionView.frame = CGRect(x: 0, y: 0.5, width: frame.size.width, height: frame.size.height - 1)
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

    override open func update(viewModel: ALKMessageViewModel) {
        self.viewModel = viewModel
        collectionView.setMessage(viewModel: viewModel)
        collectionView.reloadData()
    }
}
