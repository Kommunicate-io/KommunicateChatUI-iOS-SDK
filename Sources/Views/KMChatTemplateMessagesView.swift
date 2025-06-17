//
//  KMChatTemplateMessagesView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 27/12/17.
//

import UIKit

/*
 It's responsible to display the template message buttons.
 Currently only textual messages are supported.
 A callback is sent, when any message is selected.
 */
open class KMChatTemplateMessagesView: UIView {
    // MARK: Public properties

    open var viewModel: KMChatTemplateMessagesViewModel!

    open var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()

    /// Closure to be executed when a template message is selected
    open var messageSelected: ((KMChatTemplateMessageModel) -> Void)?

    // MARK: Intialization

    public init(frame: CGRect, viewModel: KMChatTemplateMessagesViewModel) {
        super.init(frame: frame)
        self.viewModel = viewModel
        setupViews()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private methods

    private func setupViews() {
        setupCollectionView()
    }

    private func setupCollectionView() {
        // Set datasource and delegate
        collectionView.dataSource = self
        collectionView.delegate = self

        // Register cells
        collectionView.register(KMChatTemplateMessageCell.self)

        // Set constaints
        addViewsForAutolayout(views: [collectionView])

        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension KMChatTemplateMessagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfItemsIn(section: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: KMChatTemplateMessageCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(text: viewModel.getTextForItemAt(row: indexPath.row) ?? "")
        return cell
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTemplate = viewModel.getTemplateForItemAt(row: indexPath.row) else { return }
        messageSelected?(selectedTemplate)

        // Send a notification (can be used outside the framework)
        let notificationCenter = NotificationCenter()
        notificationCenter.post(name: NSNotification.Name(rawValue: "TemplateMessageSelected"), object: selectedTemplate)
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getSizeForItemAt(row: indexPath.row)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            // Centering if there are fever pages
            let itemSize: CGSize? = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize
            let spacing: CGFloat? = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing
            let count: Int = self.collectionView(self.collectionView, numberOfItemsInSection: section)
            let totalCellWidth = (itemSize?.width ?? 0.0) * CGFloat(count)
            let totalSpacingWidth = (spacing ?? 0.0) * CGFloat(((count - 1) < 0 ? 0 : count - 1))
            let leftInset: CGFloat = (bounds.size.width - (totalCellWidth + totalSpacingWidth)) / 2 - totalCellWidth/2
            if leftInset < 0, let inset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset as? UIEdgeInsets {
                return inset
            }
            let rightInset: CGFloat = leftInset
            let sectionInset = UIEdgeInsets(top: 0, left: CGFloat(leftInset), bottom: 0, right: CGFloat(rightInset))
            return sectionInset
        }
}
