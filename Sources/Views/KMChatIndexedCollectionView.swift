//
//  KMChatIndexedCollectionView.swift
//
//  Created by Mukesh on 09/04/18.
//

import KommunicateCore_iOS_SDK
import UIKit

open class KMChatIndexedCollectionView: UICollectionView {
    open var indexPath: IndexPath!
    open var viewModel: KMChatMessageViewModel?

    override public required init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open class func rowHeightFor(message _: KMChatMessageViewModel, width _: CGFloat) -> CGFloat {
        // This should be overridden
        return 0
    }

    open func setMessage(viewModel: KMChatMessageViewModel) {
        self.viewModel = viewModel
    }
}
