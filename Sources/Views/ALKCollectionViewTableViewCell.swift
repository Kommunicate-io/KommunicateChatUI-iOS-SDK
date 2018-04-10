//
//  ALKCollectionTableViewCell.swift
//
//  Created by Mukesh on 09/04/18.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class ALKIndexedCollectionView: UICollectionView {

    var indexPath: IndexPath!

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

let collectionViewCellIdentifier: NSString = "CollectionViewCell"

class ALKCollectionTableViewCell: UITableViewCell {

    var collectionView: ALKIndexedCollectionView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 4, left: 5, bottom: 4, right: 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 91, height: 91)
        layout.scrollDirection = .horizontal

        collectionView = ALKIndexedCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .lightGray
        collectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(self.collectionView)
        layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = self.contentView.bounds
        collectionView.frame = CGRect(x: 0, y: 0.5, width: frame.size.width, height: frame.size.height - 1)
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, index: NSInteger) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.tag = index
        collectionView.reloadData()
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, indexPath: IndexPath) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.indexPath = indexPath
        collectionView.tag = indexPath.section
        collectionView.reloadData()
    }

    func register(cell: UICollectionViewCell.Type) {
        collectionView.register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
}
